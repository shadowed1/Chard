// VIRTM - Virtual Touchscreen Mouse
// Mouse capture emulation - USB mouse + trackpad support
// shadowed1
// This creates a virtual touchscreen and binds it to hardware
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <linux/uinput.h>
#include <sys/ioctl.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#include <dirent.h>
#include <math.h>

typedef enum {
    MODE_TRACKPAD,
    MODE_MOUSE
} InputMode;

InputMode input_mode = MODE_TRACKPAD;
float sensitivity   = 0.5f;
float accel         = 0.35f;
float friction      = 0.92f;
float vel_smoothing = 0.8f;
float vel_x = 0.0f;
float vel_y = 0.0f;
int finger_down = 0;
int last_mt_x   = -1;
int last_mt_y   = -1;
int mouse_btn_left  = 0;
int mouse_rel_x     = 0;
int mouse_rel_y     = 0;
int fd_input  = -1;
int fd_uinput = -1;
int tp_x_min = 0, tp_x_max = 0;
int tp_y_min = 0, tp_y_max = 0;
int ts_x_max = 19200;
int ts_y_max = 10800;
float touch_x = 0.0f;
float touch_y = 0.0f;
int current_tracking_id = 0;
int touch_active        = 0;
#define DBG(...) do { fprintf(stderr, __VA_ARGS__); fflush(stderr); } while (0)

void cleanup(int signum) {
    DBG("CLEANUP: releasing devices\n");
    if (fd_input >= 0) {
        ioctl(fd_input, EVIOCGRAB, 0);
        close(fd_input);
    }
    if (fd_uinput >= 0) {
        ioctl(fd_uinput, UI_DEV_DESTROY);
        close(fd_uinput);
    }
    exit(0);
}

int detect_touchscreen_range(const char *ts_device) {
    if (!ts_device) return -1;
    int fd = open(ts_device, O_RDONLY);
    if (fd < 0) {
        DBG("Could not open %s to detect range, using defaults\n", ts_device);
        return -1;
    }
    struct input_absinfo abs_x, abs_y;
    if (ioctl(fd, EVIOCGABS(ABS_MT_POSITION_X), &abs_x) >= 0)
        ts_x_max = abs_x.maximum;
    if (ioctl(fd, EVIOCGABS(ABS_MT_POSITION_Y), &abs_y) >= 0)
        ts_y_max = abs_y.maximum;
    close(fd);
    DBG("TOUCHSCREEN RANGE: %d x %d\n", ts_x_max, ts_y_max);
    return 0;
}

char* scan_input_device(const char *want_prop,
                        const char *reject_prop1,
                        const char *reject_prop2,
                        const char *label) {
    DIR *dir = opendir("/dev/input");
    if (!dir) { perror("Cannot open /dev/input"); return NULL; }

    struct dirent *entry;
    char device_path[256];
    char cmd[512];
    char line[256];
    char *result = NULL;

    DBG("Scanning for %s device...\n", label);

    while ((entry = readdir(dir)) != NULL) {
        if (strncmp(entry->d_name, "event", 5) != 0) continue;

        snprintf(device_path, sizeof(device_path), "/dev/input/%s", entry->d_name);
        snprintf(cmd, sizeof(cmd),
                 "udevadm info --query=property --name=%s 2>/dev/null",
                 device_path);

        FILE *fp = popen(cmd, "r");
        if (!fp) continue;

        int matched  = 0;
        int rejected = 0;

        char props[8192] = {0};
        size_t pos = 0;
        while (fgets(line, sizeof(line), fp) && pos < sizeof(props) - 1) {
            size_t len = strlen(line);
            if (pos + len < sizeof(props) - 1) {
                memcpy(props + pos, line, len);
                pos += len;
            }
        }
        pclose(fp);

        if (strstr(props, want_prop))   matched  = 1;
        if (reject_prop1 && strstr(props, reject_prop1)) rejected = 1;
        if (reject_prop2 && strstr(props, reject_prop2)) rejected = 1;

        if (matched && !rejected) {
            char name[256] = "Unknown";
            int fd = open(device_path, O_RDONLY);
            if (fd >= 0) {
                ioctl(fd, EVIOCGNAME(sizeof(name)), name);
                close(fd);
            }
            DBG("FOUND %s: %s (%s)\n", label, device_path, name);
            result = strdup(device_path);
            break;
        }
    }

    closedir(dir);
    if (!result) DBG("No %s found.\n", label);
    return result;
}

char* find_touchscreen_device() {
    return scan_input_device("ID_INPUT_TOUCHSCREEN=1", NULL, NULL, "touchscreen");
}

char* find_trackpad_device() {
    return scan_input_device("ID_INPUT_TOUCHPAD=1", NULL, NULL, "trackpad");
}

char* find_mouse_device() {
    return scan_input_device("ID_INPUT_MOUSE=1",
                             "ID_INPUT_TOUCHPAD=1",
                             "ID_INPUT_TOUCHSCREEN=1",
                             "USB mouse");
}

int detect_trackpad_bounds(int fd) {
    struct input_absinfo abs_x, abs_y;
    if (ioctl(fd, EVIOCGABS(ABS_MT_POSITION_X), &abs_x) < 0) {
        perror("Failed to get X axis info"); return -1;
    }
    if (ioctl(fd, EVIOCGABS(ABS_MT_POSITION_Y), &abs_y) < 0) {
        perror("Failed to get Y axis info"); return -1;
    }
    tp_x_min = abs_x.minimum; tp_x_max = abs_x.maximum;
    tp_y_min = abs_y.minimum; tp_y_max = abs_y.maximum;
    DBG("TRACKPAD BOUNDS: X %d..%d  Y %d..%d\n",
        tp_x_min, tp_x_max, tp_y_min, tp_y_max);
    return 0;
}

void send_event(int type, int code, int value) {
    struct input_event ev = {0};
    ev.type  = type;
    ev.code  = code;
    ev.value = value;
    write(fd_uinput, &ev, sizeof(ev));
}

void send_syn() { send_event(EV_SYN, SYN_REPORT, 0); }

void send_touch_position(int x, int y, int touching) {
    static int was_touching = 0;

    if (x < 0)          x = 0;
    if (x > ts_x_max)   x = ts_x_max;
    if (y < 0)          y = 0;
    if (y > ts_y_max)   y = ts_y_max;

    if (touching && !was_touching) {
        current_tracking_id++;
        send_event(EV_ABS, ABS_MT_SLOT,       0);
        send_event(EV_ABS, ABS_MT_TRACKING_ID, current_tracking_id);
        send_event(EV_KEY, BTN_TOUCH,          1);
        send_event(EV_ABS, ABS_MT_POSITION_X,  x);
        send_event(EV_ABS, ABS_MT_POSITION_Y,  y);
        send_event(EV_ABS, ABS_MT_TOUCH_MAJOR, 8);
        send_event(EV_ABS, ABS_MT_TOUCH_MINOR, 8);
        send_event(EV_ABS, ABS_X,              x);
        send_event(EV_ABS, ABS_Y,              y);
        send_event(EV_ABS, ABS_PRESSURE,       50);
        send_syn();
        touch_active = 1;

    } else if (touching && was_touching) {
        send_event(EV_ABS, ABS_MT_POSITION_X, x);
        send_event(EV_ABS, ABS_MT_POSITION_Y, y);
        send_event(EV_ABS, ABS_X,             x);
        send_event(EV_ABS, ABS_Y,             y);
        send_syn();

    } else if (!touching && was_touching) {
        send_event(EV_ABS, ABS_MT_TRACKING_ID, -1);
        send_event(EV_KEY, BTN_TOUCH,           0);
        send_event(EV_ABS, ABS_PRESSURE,        0);
        send_syn();
        touch_active = 0;
    }

    was_touching = touching;
}

int create_virtual_touchscreen() {
    fd_uinput = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (fd_uinput < 0) {
        perror("Failed to open /dev/uinput, run with sudo");
        return -1;
    }

    ioctl(fd_uinput, UI_SET_EVBIT,  EV_KEY);
    ioctl(fd_uinput, UI_SET_EVBIT,  EV_ABS);
    ioctl(fd_uinput, UI_SET_EVBIT,  EV_SYN);
    ioctl(fd_uinput, UI_SET_KEYBIT, BTN_TOUCH);
    ioctl(fd_uinput, UI_SET_ABSBIT, ABS_X);
    ioctl(fd_uinput, UI_SET_ABSBIT, ABS_Y);
    ioctl(fd_uinput, UI_SET_ABSBIT, ABS_PRESSURE);
    ioctl(fd_uinput, UI_SET_ABSBIT, ABS_MT_SLOT);
    ioctl(fd_uinput, UI_SET_ABSBIT, ABS_MT_TOUCH_MAJOR);
    ioctl(fd_uinput, UI_SET_ABSBIT, ABS_MT_TOUCH_MINOR);
    ioctl(fd_uinput, UI_SET_ABSBIT, ABS_MT_POSITION_X);
    ioctl(fd_uinput, UI_SET_ABSBIT, ABS_MT_POSITION_Y);
    ioctl(fd_uinput, UI_SET_ABSBIT, ABS_MT_TRACKING_ID);

    struct uinput_setup usetup = {0};
    snprintf(usetup.name, UINPUT_MAX_NAME_SIZE, "Virtual Touchscreen Mouse");
    usetup.id.bustype = BUS_I2C;
    usetup.id.vendor  = 0x27C6;
    usetup.id.product = 0x0E37;
    usetup.id.version = 1;

    #define ABS_SETUP(CODE, MIN, MAX, RES) do {           \
        struct uinput_abs_setup _a = {0};                 \
        _a.code = (CODE);                                 \
        _a.absinfo.minimum    = (MIN);                    \
        _a.absinfo.maximum    = (MAX);                    \
        _a.absinfo.resolution = (RES);                    \
        ioctl(fd_uinput, UI_ABS_SETUP, &_a);              \
    } while (0)

    ABS_SETUP(ABS_X,              0,         ts_x_max, 10);
    ABS_SETUP(ABS_Y,              0,         ts_y_max, 10);
    ABS_SETUP(ABS_PRESSURE,       0,         255,       0);
    ABS_SETUP(ABS_MT_SLOT,        0,         9,         0);
    ABS_SETUP(ABS_MT_TOUCH_MAJOR, 0,         255,       0);
    ABS_SETUP(ABS_MT_TOUCH_MINOR, 0,         255,       0);
    ABS_SETUP(ABS_MT_POSITION_X,  0,         ts_x_max, 10);
    ABS_SETUP(ABS_MT_POSITION_Y,  0,         ts_y_max, 10);
    ABS_SETUP(ABS_MT_TRACKING_ID, 0,         65535,     0);
    #undef ABS_SETUP

    if (ioctl(fd_uinput, UI_DEV_SETUP, &usetup) < 0) {
        perror("UI_DEV_SETUP failed");
        close(fd_uinput);
        return -1;
    }
    if (ioctl(fd_uinput, UI_DEV_CREATE) < 0) {
        perror("UI_DEV_CREATE failed");
        close(fd_uinput);
        return -1;
    }

    DBG("VIRTUAL TOUCHSCREEN CREATED  range: %dx%d\n", ts_x_max, ts_y_max);
    return 0;
}

void handle_event_trackpad(const struct input_event *ev) {
    if (ev->type == EV_ABS && ev->code == ABS_MT_TRACKING_ID) {
        if (ev->value == -1) {
            finger_down = 0;
            last_mt_x   = -1;
            last_mt_y   = -1;
        } else {
            finger_down = 1;
        }
        return;
    }

    if (finger_down && ev->type == EV_ABS) {
        if (ev->code == ABS_MT_POSITION_X) {
            if (last_mt_x != -1) {
                int dx = ev->value - last_mt_x;
                vel_x = vel_x * vel_smoothing + dx * accel;
            }
            last_mt_x = ev->value;
        }
        if (ev->code == ABS_MT_POSITION_Y) {
            if (last_mt_y != -1) {
                int dy = ev->value - last_mt_y;
                vel_y = vel_y * vel_smoothing + dy * accel;
            }
            last_mt_y = ev->value;
        }
    }

    if (ev->type == EV_SYN && ev->code == SYN_REPORT) {
        if (!finger_down) {
            vel_x *= friction;
            vel_y *= friction;
        }

        float dx = vel_x * sensitivity;
        float dy = vel_y * sensitivity;

        touch_x += dx;
        touch_y += dy;

        if (touch_x < 0)          touch_x += ts_x_max;
        if (touch_x > ts_x_max)   touch_x -= ts_x_max;
        if (touch_y < 0)          touch_y += ts_y_max;
        if (touch_y > ts_y_max)   touch_y -= ts_y_max;

        send_touch_position((int)(touch_x + 0.5f),
                            (int)(touch_y + 0.5f),
                            finger_down);

        if (fabs(vel_x) < 0.01f) vel_x = 0.0f;
        if (fabs(vel_y) < 0.01f) vel_y = 0.0f;
    }
}

void handle_event_mouse(const struct input_event *ev) {
    if (ev->type == EV_REL) {
        if (ev->code == REL_X) mouse_rel_x += ev->value;
        if (ev->code == REL_Y) mouse_rel_y += ev->value;
        return;
    }

    if (ev->type == EV_KEY && ev->code == BTN_LEFT) {
        if (ev->value == 1) {
            send_touch_position((int)(touch_x + 0.5f),
                                (int)(touch_y + 0.5f), 0);
            send_touch_position((int)(touch_x + 0.5f),
                                (int)(touch_y + 0.5f), 1);
        }
        return;
    }

    if (ev->type == EV_SYN && ev->code == SYN_REPORT) {
        if (mouse_rel_x != 0 || mouse_rel_y != 0) {
            touch_x += mouse_rel_x * accel * sensitivity;
            touch_y += mouse_rel_y * accel * sensitivity;
            mouse_rel_x = 0;
            mouse_rel_y = 0;
            if (touch_x < 0)          touch_x = 0;
            if (touch_x > ts_x_max)   touch_x = ts_x_max;
            if (touch_y < 0)          touch_y = 0;
            if (touch_y > ts_y_max)   touch_y = ts_y_max;
        }

        send_touch_position((int)(touch_x + 0.5f),
                            (int)(touch_y + 0.5f), 1);
    }
}

int main(int argc, char *argv[]) {
    char *input_device      = NULL;
    char *touchscreen_device = NULL;

    if (argc > 1) input_device       = argv[1];
    if (argc > 2) touchscreen_device = argv[2];
    if (argc > 3) sensitivity        = atof(argv[3]);
    if (argc > 4) accel              = atof(argv[4]);
    if (argc > 5) friction           = atof(argv[5]);

    signal(SIGINT,  cleanup);
    signal(SIGTERM, cleanup);

    DBG("VIRTM - Virtual Touchscreen Mouse\n");
    DBG("Sensitivity: %.2f | Accel: %.2f | Friction: %.2f\n",
        sensitivity, accel, friction);

    if (!touchscreen_device)
        touchscreen_device = find_touchscreen_device();
    detect_touchscreen_range(touchscreen_device);
    if (!input_device) {
        char *mouse_path = find_mouse_device();
        if (mouse_path) {
            input_device = mouse_path;
            input_mode   = MODE_MOUSE;
            DBG("INPUT MODE: USB mouse  (%s)\n", input_device);
        } else {
            input_device = find_trackpad_device();
            input_mode   = MODE_TRACKPAD;
            if (input_device)
                DBG("INPUT MODE: trackpad  (%s)\n", input_device);
        }
    } else {
        int probe_fd = open(input_device, O_RDONLY);
        if (probe_fd >= 0) {
            unsigned long evbits[EV_MAX / (8*sizeof(unsigned long)) + 1] = {0};
            ioctl(probe_fd, EVIOCGBIT(0, sizeof(evbits)), evbits);
            if (evbits[EV_REL / (8*sizeof(unsigned long))]
                    & (1UL << (EV_REL % (8*sizeof(unsigned long))))) {
                input_mode = MODE_MOUSE;
                DBG("INPUT MODE: USB mouse (explicit, REL axes detected)\n");
            } else {
                input_mode = MODE_TRACKPAD;
                DBG("INPUT MODE: trackpad (explicit)\n");
            }
            close(probe_fd);
        }
    }

    if (!input_device) {
        DBG("No suitable input device found.\n");
        DBG("Usage: %s [input_dev] [touchscreen_dev] [sensitivity] [accel] [friction]\n",
            argv[0]);
        DBG("Example: %s /dev/input/event4 /dev/input/event5 0.4 0.25 0.92\n", argv[0]);
        DBG("Run in Chard with: sudo %s\n", argv[0]);
        return 1;
    }

    fd_input = open(input_device, O_RDONLY);
    if (fd_input < 0) {
        perror("Failed to open input device");
        return 1;
    }

    if (input_mode == MODE_TRACKPAD) {
        if (detect_trackpad_bounds(fd_input) < 0) {
            close(fd_input);
            return 1;
        }
        if (ioctl(fd_input, EVIOCGRAB, 1) < 0) {
            perror("EVIOCGRAB failed");
            close(fd_input);
            return 1;
        }
        DBG("Trackpad grabbed.\n");
    } else {
        if (ioctl(fd_input, EVIOCGRAB, 1) < 0) {
            perror("EVIOCGRAB failed on mouse");
            close(fd_input);
            return 1;
        }
        DBG("USB mouse grabbed (trackpad can be used normally!).\n");
    }

    if (create_virtual_touchscreen() < 0) {
        ioctl(fd_input, EVIOCGRAB, 0);
        close(fd_input);
        return 1;
    }

    touch_x = ts_x_max / 2.0f;
    touch_y = ts_y_max / 2.0f;

    if (input_mode == MODE_MOUSE)
        send_touch_position((int)touch_x, (int)touch_y, 1);

    DBG("Ready. Ctrl+C to exit.\n\n");

    struct input_event ev;
    while (1) {
        ssize_t n = read(fd_input, &ev, sizeof(ev));
        if (n != sizeof(ev)) continue;

        if (input_mode == MODE_MOUSE)
            handle_event_mouse(&ev);
        else
            handle_event_trackpad(&ev);
    }

    cleanup(0);
    return 0;
}
