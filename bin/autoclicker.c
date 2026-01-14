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

// ======================
// ChromeOS Autoclicker by Wilds
// ======================

#define MAX_CPS 1000

int fd_uinput = -1;

void cleanup(int signum) {
    fprintf(stderr, "\nCLEANUP: releasing uinput device\n");
    if (fd_uinput >= 0) {
        ioctl(fd_uinput, UI_DEV_DESTROY);
        close(fd_uinput);
    }
    exit(0);
}

void emit_click(int fd) {
    struct input_event ev;

    // Button down
    memset(&ev, 0, sizeof(ev));
    ev.type = EV_KEY;
    ev.code = BTN_LEFT;
    ev.value = 1;
    write(fd, &ev, sizeof(ev));

    memset(&ev, 0, sizeof(ev));
    ev.type = EV_SYN;
    ev.code = SYN_REPORT;
    write(fd, &ev, sizeof(ev));

    // Button up
    memset(&ev, 0, sizeof(ev));
    ev.type = EV_KEY;
    ev.code = BTN_LEFT;
    ev.value = 0;
    write(fd, &ev, sizeof(ev));

    memset(&ev, 0, sizeof(ev));
    ev.type = EV_SYN;
    ev.code = SYN_REPORT;
    write(fd, &ev, sizeof(ev));
}

int main(int argc, char *argv[]) {
    signal(SIGINT, cleanup);
    signal(SIGTERM, cleanup);

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <Clicks Per Second Value>\n", argv[0]);
        return 1;
    }

    double cps = atof(argv[1]);
    if (cps <= 0) {
        fprintf(stderr, "Invalid clicks per second: %s\n", argv[1]);
        return 1;
    }

    // ---- HARD CPS LIMIT ----
    if (cps > MAX_CPS) {
        fprintf(stderr,
                "Warning: CPS %.2f exceeds maximum allowed (%d). Clamping.\n",
                cps, MAX_CPS);
        cps = MAX_CPS;
    }

    unsigned int delay_us = (unsigned int)(1000000.0 / cps);

    fd_uinput = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (fd_uinput < 0) {
        perror("Failed to open /dev/uinput");
        return 1;
    }

    if (ioctl(fd_uinput, UI_SET_EVBIT, EV_KEY) < 0 ||
        ioctl(fd_uinput, UI_SET_KEYBIT, BTN_LEFT) < 0) {
        perror("Failed to setup uinput device");
        cleanup(0);
    }

    struct uinput_setup usetup;
    memset(&usetup, 0, sizeof(usetup));
    snprintf(usetup.name, UINPUT_MAX_NAME_SIZE, "ChromeOS Autoclicker");
    usetup.id.bustype = BUS_USB;
    usetup.id.vendor  = 0x1234;
    usetup.id.product = 0x5678;
    usetup.id.version = 1;

    if (ioctl(fd_uinput, UI_DEV_SETUP, &usetup) < 0 ||
        ioctl(fd_uinput, UI_DEV_CREATE) < 0) {
        perror("Failed to create uinput device");
        cleanup(0);
    }

    fprintf(stderr, "ChromeOS_Autoclicker will start in 10 seconds!\n");
    sleep(10);
    fprintf(stderr, "Started - %.2f clicks/sec (max %d). Ctrl+C to exit.\n",
            cps, MAX_CPS);

    while (1) {
        emit_click(fd_uinput);
        usleep(delay_us);
    }

    cleanup(0);
    return 0;
}
