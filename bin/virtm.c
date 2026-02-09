// VIRTM - Virtual Touchscreen Mouse
// Mouse capture emulation
// shadowed 1
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

float sensitivity = 0.4f;
float accel = 0.25f;
float friction = 0.92f;
float vel_smoothing = 0.8f;

float vel_x = 0.0f;
float vel_y = 0.0f;

int finger_down = 0;
int last_mt_x = -1;
int last_mt_y = -1;

int fd_trackpad = -1;
int fd_uinput = -1;

int tp_x_min = 0;
int tp_x_max = 0;
int tp_y_min = 0;
int tp_y_max = 0;

int ts_x_max = 9600;
int ts_y_max = 5400;

int touch_x = 0;
int touch_y = 0;

int current_tracking_id = 0;
int touch_active = 0;

#define DBG(...) do { fprintf(stderr, __VA_ARGS__); fflush(stderr); } while (0)

void cleanup(int signum) {
    DBG("\n═══════════════════════════════════════════\n");
    DBG("CLEANUP: releasing devices\n");
    DBG("═══════════════════════════════════════════\n");
    if (fd_trackpad >= 0) {
        ioctl(fd_trackpad, EVIOCGRAB, 0);
        close(fd_trackpad);
    }
    if (fd_uinput >= 0) {
        ioctl(fd_uinput, UI_DEV_DESTROY);
        close(fd_uinput);
    }
    exit(0);
}

int detect_touchscreen_range(const char *ts_device) {
    int fd = open(ts_device, O_RDONLY);
    if (fd < 0) {
        DBG("Could not open %s to detect range, using defaults\n", ts_device);
        return -1;
    }
    
    struct input_absinfo abs_x, abs_y;
    
    if (ioctl(fd, EVIOCGABS(ABS_MT_POSITION_X), &abs_x) >= 0) {
        ts_x_max = abs_x.maximum;
    }
    
    if (ioctl(fd, EVIOCGABS(ABS_MT_POSITION_Y), &abs_y) >= 0) {
        ts_y_max = abs_y.maximum;
    }
    
    close(fd);
    
    DBG("═══════════════════════════════════════════\n");
    DBG("TOUCHSCREEN RANGE DETECTED:\n");
    DBG("  X: 0 to %d\n", ts_x_max);
    DBG("  Y: 0 to %d\n", ts_y_max);
    DBG("═══════════════════════════════════════════\n");
    
    return 0;
}

char* find_touchscreen_device() {
    DIR *dir = opendir("/dev/input");
    if (!dir) {
        perror("Cannot open /dev/input");
        return NULL;
    }
    
    struct dirent *entry;
    static char device_path[256];
    char cmd[512];
    FILE *fp;
    char line[256];
    
    DBG("═══════════════════════════════════════════\n");
    DBG("Scanning for touchscreen device (udevadm)...\n");
    DBG("═══════════════════════════════════════════\n");
    
    while ((entry = readdir(dir)) != NULL) {
        if (strncmp(entry->d_name, "event", 5) != 0) continue;
        
        snprintf(device_path, sizeof(device_path), "/dev/input/%s", entry->d_name);
        snprintf(cmd, sizeof(cmd), "udevadm info --query=property --name=%s 2>/dev/null", device_path);
        fp = popen(cmd, "r");
        if (!fp) continue;
        
        int is_touchscreen = 0;
        while (fgets(line, sizeof(line), fp)) {
            if (strstr(line, "ID_INPUT_TOUCHSCREEN=1")) {
                is_touchscreen = 1;
                break;
            }
        }
        pclose(fp);
        
        if (is_touchscreen) {
            char name[256] = "Unknown";
            int fd = open(device_path, O_RDONLY);
            if (fd >= 0) {
                ioctl(fd, EVIOCGNAME(sizeof(name)), name);
                close(fd);
            }
            
            DBG("\nFOUND TOUCHSCREEN: %s (%s)\n", device_path, name);
            closedir(dir);
            return strdup(device_path);
        }
    }
    
    closedir(dir);
    DBG("\nNo touchscreen found\n");
    return NULL;
}

char* find_trackpad_device() {
    DIR *dir = opendir("/dev/input");
    if (!dir) {
        perror("Cannot open /dev/input");
        return NULL;
    }
    
    struct dirent *entry;
    static char device_path[256];
    char cmd[512];
    FILE *fp;
    char line[256];
    
    DBG("═══════════════════════════════════════════\n");
    DBG("Scanning for trackpad device (udevadm)...\n");
    DBG("═══════════════════════════════════════════\n");
    
    while ((entry = readdir(dir)) != NULL) {
        if (strncmp(entry->d_name, "event", 5) != 0) continue;
        
        snprintf(device_path, sizeof(device_path), "/dev/input/%s", entry->d_name);
        snprintf(cmd, sizeof(cmd), "udevadm info --query=property --name=%s 2>/dev/null", device_path);
        fp = popen(cmd, "r");
        if (!fp) continue;
        
        int is_touchpad = 0;
        while (fgets(line, sizeof(line), fp)) {
            if (strstr(line, "ID_INPUT_TOUCHPAD=1")) {
                is_touchpad = 1;
                break;
            }
        }
        pclose(fp);
        
        if (is_touchpad) {
            char name[256] = "Unknown";
            int fd = open(device_path, O_RDONLY);
            if (fd >= 0) {
                ioctl(fd, EVIOCGNAME(sizeof(name)), name);
                close(fd);
            }
            
            DBG("\nFOUND TRACKPAD: %s (%s)\n", device_path, name);
            closedir(dir);
            return strdup(device_path);
        }
    }
    
    closedir(dir);
    DBG("\nNo trackpad found\n");
    return NULL;
}

int detect_trackpad_bounds(int fd) {
    struct input_absinfo abs_x, abs_y;
    
    if (ioctl(fd, EVIOCGABS(ABS_MT_POSITION_X), &abs_x) < 0) {
        perror("Failed to get X axis info");
        return -1;
    }
    
    if (ioctl(fd, EVIOCGABS(ABS_MT_POSITION_Y), &abs_y) < 0) {
        perror("Failed to get Y axis info");
        return -1;
    }
    
    tp_x_min = abs_x.minimum;
    tp_x_max = abs_x.maximum;
    tp_y_min = abs_y.minimum;
    tp_y_max = abs_y.maximum;
    
    DBG("═══════════════════════════════════════════\n");
    DBG("TRACKPAD BOUNDS:\n");
    DBG("  X: %d to %d\n", tp_x_min, tp_x_max);
    DBG("  Y: %d to %d\n", tp_y_min, tp_y_max);
    DBG("═══════════════════════════════════════════\n");
    
    return 0;
}

void send_event(int type, int code, int value) {
    struct input_event ev = {0};
    ev.type = type;
    ev.code = code;
    ev.value = value;
    write(fd_uinput, &ev, sizeof(ev));
}

void send_syn() {
    send_event(EV_SYN, SYN_REPORT, 0);
}

void send_touch_position(int x, int y, int touching) {
    static int was_touching = 0;
    
    if (x < 0) x = 0;
    if (x > ts_x_max) x = ts_x_max;
    if (y < 0) y = 0;
    if (y > ts_y_max) y = ts_y_max;
    
    if (touching && !was_touching) {
        current_tracking_id++;
        
        send_event(EV_ABS, ABS_MT_SLOT, 0);
        send_event(EV_ABS, ABS_MT_TRACKING_ID, current_tracking_id);
        send_event(EV_KEY, BTN_TOUCH, 1);
        send_event(EV_ABS, ABS_MT_POSITION_X, x);
        send_event(EV_ABS, ABS_MT_POSITION_Y, y);
        send_event(EV_ABS, ABS_MT_TOUCH_MAJOR, 8);
        send_event(EV_ABS, ABS_MT_TOUCH_MINOR, 8);
        send_event(EV_ABS, ABS_X, x);
        send_event(EV_ABS, ABS_Y, y);
        send_event(EV_ABS, ABS_PRESSURE, 50);
        send_syn();
        
        touch_active = 1;
        DBG("TOUCH DOWN at (%d, %d)\n", x, y);
        
    } else if (touching && was_touching) {
        send_event(EV_ABS, ABS_MT_POSITION_X, x);
        send_event(EV_ABS, ABS_MT_POSITION_Y, y);
        send_event(EV_ABS, ABS_X, x);
        send_event(EV_ABS, ABS_Y, y);
        send_syn();
        
    } else if (!touching && was_touching) {
        send_event(EV_ABS, ABS_MT_TRACKING_ID, -1);
        send_event(EV_KEY, BTN_TOUCH, 0);
        send_event(EV_ABS, ABS_PRESSURE, 0);
        send_syn();
        
        touch_active = 0;
        DBG("TOUCH UP\n");
    }
    
    was_touching = touching;
}

int create_virtual_touchscreen() {
    fd_uinput = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (fd_uinput < 0) {
        perror("Failed to open /dev/uinput");
        return -1;
    }
    
    ioctl(fd_uinput, UI_SET_EVBIT, EV_KEY);
    ioctl(fd_uinput, UI_SET_EVBIT, EV_ABS);
    ioctl(fd_uinput, UI_SET_EVBIT, EV_SYN);
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
    snprintf(usetup.name, UINPUT_MAX_NAME_SIZE, "Virtual Goodix Touchscreen");
    usetup.id.bustype = BUS_I2C;
    usetup.id.vendor  = 0x27C6;
    usetup.id.product = 0x0E37;
    usetup.id.version = 1;
    
    struct uinput_abs_setup abs_x = {0};
    abs_x.code = ABS_X;
    abs_x.absinfo.minimum = 0;
    abs_x.absinfo.maximum = ts_x_max;
    abs_x.absinfo.resolution = 10;
    ioctl(fd_uinput, UI_ABS_SETUP, &abs_x);
    
    struct uinput_abs_setup abs_y = {0};
    abs_y.code = ABS_Y;
    abs_y.absinfo.minimum = 0;
    abs_y.absinfo.maximum = ts_y_max;
    abs_y.absinfo.resolution = 10;
    ioctl(fd_uinput, UI_ABS_SETUP, &abs_y);
    
    struct uinput_abs_setup abs_pressure = {0};
    abs_pressure.code = ABS_PRESSURE;
    abs_pressure.absinfo.minimum = 0;
    abs_pressure.absinfo.maximum = 255;
    ioctl(fd_uinput, UI_ABS_SETUP, &abs_pressure);
    
    struct uinput_abs_setup abs_mt_x = {0};
    abs_mt_x.code = ABS_MT_POSITION_X;
    abs_mt_x.absinfo.minimum = 0;
    abs_mt_x.absinfo.maximum = ts_x_max;
    abs_mt_x.absinfo.resolution = 10;
    ioctl(fd_uinput, UI_ABS_SETUP, &abs_mt_x);
    
    struct uinput_abs_setup abs_mt_y = {0};
    abs_mt_y.code = ABS_MT_POSITION_Y;
    abs_mt_y.absinfo.minimum = 0;
    abs_mt_y.absinfo.maximum = ts_y_max;
    abs_mt_y.absinfo.resolution = 10;
    ioctl(fd_uinput, UI_ABS_SETUP, &abs_mt_y);
    
    struct uinput_abs_setup abs_slot = {0};
    abs_slot.code = ABS_MT_SLOT;
    abs_slot.absinfo.minimum = 0;
    abs_slot.absinfo.maximum = 9;
    ioctl(fd_uinput, UI_ABS_SETUP, &abs_slot);
    
    struct uinput_abs_setup abs_major = {0};
    abs_major.code = ABS_MT_TOUCH_MAJOR;
    abs_major.absinfo.minimum = 0;
    abs_major.absinfo.maximum = 255;
    ioctl(fd_uinput, UI_ABS_SETUP, &abs_major);
    
    struct uinput_abs_setup abs_minor = {0};
    abs_minor.code = ABS_MT_TOUCH_MINOR;
    abs_minor.absinfo.minimum = 0;
    abs_minor.absinfo.maximum = 255;
    ioctl(fd_uinput, UI_ABS_SETUP, &abs_minor);
    
    struct uinput_abs_setup abs_tracking = {0};
    abs_tracking.code = ABS_MT_TRACKING_ID;
    abs_tracking.absinfo.minimum = 0;
    abs_tracking.absinfo.maximum = 65535;
    ioctl(fd_uinput, UI_ABS_SETUP, &abs_tracking);
    
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
    
    DBG("═══════════════════════════════════════════\n");
    DBG("VIRTUAL TOUCHSCREEN CREATED\n");
    DBG("  Range: %d x %d\n", ts_x_max, ts_y_max);
    DBG("═══════════════════════════════════════════\n");
    
    return 0;
}

int main(int argc, char *argv[]) {
    char *trackpad_device = NULL;
    char *touchscreen_device = NULL;
    if (argc > 1) trackpad_device = argv[1];
    if (argc > 2) touchscreen_device = argv[2];
    if (argc > 3) sensitivity = atof(argv[3]);
    if (argc > 4) accel = atof(argv[4]);
    if (argc > 5) friction = atof(argv[5]);
    
    signal(SIGINT, cleanup);
    signal(SIGTERM, cleanup);
    
    DBG("═══════════════════════════════════════════\n");
    DBG("VIRTM - Virtual Touchscreen Mouse\n");
    DBG("Sensitivity: %.2f | Accel: %.2f | Friction: %.2f\n", sensitivity, accel, friction);
    DBG("═══════════════════════════════════════════\n\n");
    if (!touchscreen_device) {
        touchscreen_device = find_touchscreen_device();
    }
    
    detect_touchscreen_range(touchscreen_device);
    if (!trackpad_device) {
        trackpad_device = find_trackpad_device();
        if (!trackpad_device) {
            DBG("\nUsage: %s [trackpad] [touchscreen] [sensitivity] [accel] [friction]\n", argv[0]);
            DBG("Example: %s /dev/input/event4 /dev/input/event5 0.4 0.25 0.92\n", argv[0]);
            DBG("Or just: sudo %s (auto-detect everything)\n", argv[0]);
            DBG("\nDefaults: sensitivity=0.4, accel=0.25, friction=0.92\n");
            return 1;
        }
    }
    
    fd_trackpad = open(trackpad_device, O_RDONLY);
    if (fd_trackpad < 0) {
        perror("Failed to open trackpad");
        return 1;
    }
    
    if (detect_trackpad_bounds(fd_trackpad) < 0) {
        close(fd_trackpad);
        return 1;
    }
    
    if (ioctl(fd_trackpad, EVIOCGRAB, 1) < 0) {
        perror("EVIOCGRAB failed");
        close(fd_trackpad);
        return 1;
    }
    
    DBG("Trackpad grabbed: %s\n\n", trackpad_device);
    
    if (create_virtual_touchscreen() < 0) {
        ioctl(fd_trackpad, EVIOCGRAB, 0);
        close(fd_trackpad);
        return 1;
    }
    
    touch_x = ts_x_max / 2;
    touch_y = ts_y_max / 2;
    
    DBG("═══════════════════════════════════════════\n");
    DBG("READY! Press Ctrl+C to exit.\n");
    DBG("═══════════════════════════════════════════\n\n");
    
    struct input_event ev;
    
    while (1) {
        ssize_t n = read(fd_trackpad, &ev, sizeof(ev));
        if (n != sizeof(ev)) continue;
        
        if (ev.type == EV_ABS && ev.code == ABS_MT_TRACKING_ID) {
            if (ev.value == -1) {
                finger_down = 0;
                last_mt_x = -1;
                last_mt_y = -1;
                DBG("FINGER UP\n");
            } else {
                finger_down = 1;
                DBG("FINGER DOWN (id=%d)\n", ev.value);
            }
        }
        
        if (finger_down && ev.type == EV_ABS) {
            if (ev.code == ABS_MT_POSITION_X) {
                if (last_mt_x != -1) {
                    int dx_raw = ev.value - last_mt_x;
                    vel_x = vel_x * vel_smoothing + dx_raw * accel;
                }
                last_mt_x = ev.value;
            }
            
            if (ev.code == ABS_MT_POSITION_Y) {
                if (last_mt_y != -1) {
                    int dy_raw = ev.value - last_mt_y;
                    vel_y = vel_y * vel_smoothing + dy_raw * accel;
                }
                last_mt_y = ev.value;
            }
        }
        
        if (ev.type == EV_SYN && ev.code == SYN_REPORT) {
            if (!finger_down) {
                vel_x *= friction;
                vel_y *= friction;
            }
            
            int dx = (int)(vel_x * sensitivity);
            int dy = (int)(vel_y * sensitivity);
            
            if (dx || dy) {
                touch_x += dx;
                touch_y += dy;
                
                if (touch_x < 0) touch_x += ts_x_max;
                if (touch_x > ts_x_max) touch_x -= ts_x_max;
                if (touch_y < 0) touch_y += ts_y_max;
                if (touch_y > ts_y_max) touch_y -= ts_y_max;
                
                DBG("Move: vel=(%.2f,%.2f) pos=(%d,%d)\n", vel_x, vel_y, touch_x, touch_y);
            }
            
            send_touch_position(touch_x, touch_y, finger_down);
            
            if (fabs(vel_x) < 0.1f) vel_x = 0.0f;
            if (fabs(vel_y) < 0.1f) vel_y = 0.0f;
        }
    }
    
    cleanup(0);
    return 0;
}
