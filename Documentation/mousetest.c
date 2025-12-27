#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <errno.h>
#include <string.h>

int main(int argc, char *argv[]) {
    const char *dev = "/dev/input/event4"; // My Lenovo Chromebook touchpad
    if (argc > 1) dev = argv[1];

    int fd = open(dev, O_RDONLY);
    if (fd < 0) {
        perror("Failed to open device");
        return 1;
    }

    struct input_event ev;
    int last_x = -1, last_y = -1;

    printf("Reading mouse events from %s (Ctrl+C to exit)\n", dev);

    while (1) {
        ssize_t n = read(fd, &ev, sizeof(ev));
        if (n != sizeof(ev)) {
            fprintf(stderr, "Read error: %zd %s\n", n, strerror(errno));
            continue;
        }

        if (ev.type == EV_ABS) {
            if (ev.code == ABS_X) {
                if (last_x != -1) printf("REL_X: %d ", ev.value - last_x);
                last_x = ev.value;
            }
            if (ev.code == ABS_Y) {
                if (last_y != -1) printf("REL_Y: %d\n", ev.value - last_y);
                last_y = ev.value;
            }
        }
    }

    close(fd);
    return 0;
}
