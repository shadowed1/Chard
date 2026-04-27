#!/bin/bash
# Thanks to Days for making this checkpoint

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

if [[ "$ARCH" != "x86_64" ]]; then
    echo "${YELLOW}Unsupported architecture: $ARCH${RESET}"
    sleep 3
    exit 0
fi

sudo pacman -R --noconfirm gpu-screen-recorder-ui 2>/dev/null
sudo pacman -R --noconfirm gpu-screen-recorder-notification 2>/dev/null

sudo -E pacman -S --needed --noconfirm git gcc make meson ninja pkgconf python
sudo -E pacman -S --needed --noconfirm ffmpeg libva libva-utils libdrm mesa mesa-demos vulkan-headers vulkan-icd-loader
sudo -E pacman -S --needed --noconfirm wayland wayland-protocols libx11 libxcomposite libxrandr libxfixes libxdamage libpulse pipewire dbus libcap

cd /tmp
sudo rm -rf /tmp/gpu-screen-recorder* 2>/dev/null
mkdir -p /tmp/gpu-screen-recorder
wget -c -P /tmp/ https://dec05eba.com/snapshot/gpu-screen-recorder.git.5.13.3.tar.gz
tar -xf /tmp/gpu-screen-recorder.git.5.13.3.tar.gz -C /tmp/gpu-screen-recorder
cd /tmp/gpu-screen-recorder

cp -n src/window/wayland.c src/window/wayland.c.orig
cp -n src/main.cpp src/main.cpp.orig

    python3 - <<'PY'
from pathlib import Path
import re

# -----------------------------
# Patch src/window/wayland.c
# -----------------------------

p = Path("src/window/wayland.c")
s = p.read_text()

old = '''    } else if(strcmp(interface, wl_output_interface.name) == 0) {
        if(version < 4) {
            fprintf(stderr, "gsr warning: wl output interface version is < 4, expected >= 4 to capture a monitor\\n");
            return;
        }

        if(window_wayland->num_outputs == GSR_MAX_OUTPUTS) {'''

new = '''    } else if(strcmp(interface, wl_output_interface.name) == 0) {
        const uint32_t output_version = version < 4 ? version : 4;

        if(version < 4) {
            fprintf(stderr, "gsr warning: wl output interface version is < 4; continuing with limited wl_output metadata\\n");
        }

        if(window_wayland->num_outputs == GSR_MAX_OUTPUTS) {'''

if old in s:
    s = s.replace(old, new, 1)
elif "const uint32_t output_version = version < 4 ? version : 4;" not in s:
    raise SystemExit("Could not patch wl_output version guard in src/window/wayland.c")

s = s.replace(
    '''            .output = wl_registry_bind(registry, name, &wl_output_interface, 4),''',
    '''            .output = wl_registry_bind(registry, name, &wl_output_interface, output_version),'''
)

listener = '''        wl_output_add_listener(gsr_output->output, &output_listener, gsr_output);'''

fallback = '''        wl_output_add_listener(gsr_output->output, &output_listener, gsr_output);

        if(output_version < 4 && !gsr_output->name) {
            char fallback_output_name[32];
            snprintf(fallback_output_name, sizeof(fallback_output_name), "WL-%u", name);
            gsr_output->name = strdup(fallback_output_name);
        }'''

if "fallback_output_name" not in s:
    if listener not in s:
        raise SystemExit("Could not find wl_output_add_listener line")
    s = s.replace(listener, fallback, 1)

function_header = '''static void gsr_window_wayland_set_monitor_outputs_from_xdg_output(gsr_window_wayland *self) {
'''
if function_header in s:
    start = s.index(function_header) + len(function_header)
    nearby = s[start:start + 300]
    if "if(!self->xdg_output_manager)" not in nearby:
        s = s[:start] + '''    if(!self->xdg_output_manager) {
        fprintf(stderr, "gsr warning: zxdg_output_manager not found. registered monitor positions might be incorrect\\n");
        return;
    }

''' + s[start:]

old_loop = '''    for(int i = 0; i < self->num_outputs; ++i) {
        self->outputs[i].xdg_output = zxdg_output_manager_v1_get_xdg_output(self->xdg_output_manager, self->outputs[i].output);
        zxdg_output_v1_add_listener(self->outputs[i].xdg_output, &xdg_output_listener, &self->outputs[i]);
    }'''

new_loop = '''    for(int i = 0; i < self->num_outputs; ++i) {
        if(!self->outputs[i].output) {
            fprintf(stderr, "gsr warning: wl_output is null for output %d, skipping xdg output setup\\n", i);
            continue;
        }

        self->outputs[i].xdg_output = zxdg_output_manager_v1_get_xdg_output(self->xdg_output_manager, self->outputs[i].output);
        if(!self->outputs[i].xdg_output) {
            fprintf(stderr, "gsr warning: failed to create xdg_output for output %d, monitor position/name metadata may be incomplete\\n", i);
            continue;
        }

        zxdg_output_v1_add_listener(self->outputs[i].xdg_output, &xdg_output_listener, &self->outputs[i]);
    }'''

if old_loop in s:
    s = s.replace(old_loop, new_loop, 1)

s = s.replace(
'''            zxdg_output_v1_destroy(self->outputs[i].xdg_output);
            self->outputs[i].output = NULL;''',
'''            zxdg_output_v1_destroy(self->outputs[i].xdg_output);
            self->outputs[i].xdg_output = NULL;'''
)

s = re.sub(r'^\s*fprintf\(stderr, "GSRDBG[^;]+;\n', '', s, flags=re.M)

p.write_text(s)

# -----------------------------
# Patch src/main.cpp
# -----------------------------

p = Path("src/main.cpp")
s = p.read_text()

old = '''static bool is_xwayland(Display *display) {
    int opcode, event, error;
    if(XQueryExtension(display, "XWAYLAND", &opcode, &event, &error))
        return true;

    bool xwayland_found = false;
    for_each_active_monitor_output_x11_not_cached(display, xwayland_check_callback, &xwayland_found);
    return xwayland_found;
}'''

new = '''static bool is_xwayland(Display *display) {
    const char *force_x11_env = getenv("GSR_FORCE_X11");
    if(force_x11_env && strcmp(force_x11_env, "0") != 0) {
        fprintf(stderr, "gsr warning: GSR_FORCE_X11 is set; treating Xwayland as X11\\n");
        return false;
    }

    int opcode, event, error;
    if(XQueryExtension(display, "XWAYLAND", &opcode, &event, &error))
        return true;

    bool xwayland_found = false;
    for_each_active_monitor_output_x11_not_cached(display, xwayland_check_callback, &xwayland_found);
    return xwayland_found;
}'''

if old in s:
    s = s.replace(old, new, 1)
elif "GSR_FORCE_X11 is set; treating Xwayland as X11" not in s:
    raise SystemExit("Could not patch is_xwayland in src/main.cpp")

old = '''    bool wayland = false;
    setup.dpy = XOpenDisplay(nullptr);
    if (!setup.dpy) {
        wayland = true;
        fprintf(stderr, "gsr warning: failed to connect to the X server. Assuming wayland is running without Xwayland\\n");
    }

    XSetErrorHandler(x11_error_handler);
    XSetIOErrorHandler(x11_io_error_handler);

    if(!wayland)
        wayland = is_xwayland(setup.dpy);'''

new = '''    const char *force_x11_env = getenv("GSR_FORCE_X11");
    const bool force_x11 = force_x11_env && strcmp(force_x11_env, "0") != 0;

    bool wayland = false;
    setup.dpy = XOpenDisplay(nullptr);
    if (!setup.dpy) {
        if(force_x11) {
            fprintf(stderr, "gsr error: GSR_FORCE_X11 is set but failed to connect to the X server\\n");
            _exit(1);
        }

        wayland = true;
        fprintf(stderr, "gsr warning: failed to connect to the X server. Assuming wayland is running without Xwayland\\n");
    }

    XSetErrorHandler(x11_error_handler);
    XSetIOErrorHandler(x11_io_error_handler);

    if(force_x11) {
        wayland = false;
        fprintf(stderr, "gsr warning: GSR_FORCE_X11 is set; forcing X11 windowing even if the X server reports Xwayland\\n");
    } else if(!wayland) {
        wayland = is_xwayland(setup.dpy);
    }'''

if old in s:
    s = s.replace(old, new, 1)
elif "GSR_FORCE_X11 is set; forcing X11 windowing even if the X server reports Xwayland" not in s:
    raise SystemExit("Could not patch setup_windowing in src/main.cpp")

p.write_text(s)

print("gpu-screen-recorder ChromeOS patches applied")
PY

meson setup build \
  --prefix=/usr \
  --libdir=/usr/lib \
  --buildtype=release \
  -Dstrip=true \
  -Dportal=false

meson compile -C build
sudo meson install -C build
hash -r

cd "$HOME"
rm -rf /tmp/gpu-screen-recorder

# The UI package depends on the packaged gpu-screen-recorder version.
# We install gpu-screen-recorder from patched source, so pacman is told to treat it as present.
# Revisit this assumed version if Arch updates gpu-screen-recorder-ui to require a newer GSR.

# sudo -E pacman -S --needed --noconfirm gpu-screen-recorder-ui gpu-screen-recorder-notification

[[ -x /usr/bin/gpu-screen-recorder ]]
[[ -x /usr/bin/gsr-ui ]]

strings /usr/bin/gpu-screen-recorder | grep -F "wl output interface version is < 4; continuing with limited wl_output metadata" >/dev/null
strings /usr/bin/gpu-screen-recorder | grep -F "GSR_FORCE_X11 is set; treating Xwayland as X11" >/dev/null
strings /usr/bin/gpu-screen-recorder | grep -F "GSR_FORCE_X11 is set; forcing X11 windowing even if the X server reports Xwayland" >/dev/null

    sudo tee /bin/chard_gpusrc >/dev/null <<'GPUSR_CLI_EOF'
#!/bin/bash
exec env \
  GSR_FORCE_X11=1 \
  __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS="" \
  WAYLAND_DISPLAY="" \
  DISPLAY=:0 \
  EGL_PLATFORM=x11 \
  LD_LIBRARY_PATH=/usr/lib:/usr/lib64 \
  LIBGL_DRIVERS_PATH=/usr/lib64/dri \
  LIBEGL_DRIVERS_PATH=/usr/lib64/dri \
  /usr/bin/gpu-screen-recorder "$@"
GPUSR_CLI_EOF
    sudo chmod +x /bin/chard_gpusrc

    sudo tee /bin/chard_gpusr >/dev/null <<'GPUSR_UI_EOF'
#!/bin/bash
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/chrome}"
SOCKET="$RUNTIME_DIR/gsr-ui"
mkdir -p "$RUNTIME_DIR" 2>/dev/null || true
if [ -S "$SOCKET" ] && ! pgrep -u "$(id -u)" -x gsr-ui >/dev/null 2>&1; then
  rm -f "$SOCKET"
fi
exec env \
  GSR_FORCE_X11=1 \
  __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS="" \
  WAYLAND_DISPLAY="" \
  DISPLAY=:0 \
  EGL_PLATFORM=x11 \
  LD_LIBRARY_PATH=/usr/lib:/usr/lib64 \
  LIBGL_DRIVERS_PATH=/usr/lib64/dri \
  LIBEGL_DRIVERS_PATH=/usr/lib64/dri \
  /usr/bin/gsr-ui launch-show
GPUSR_UI_EOF
    sudo chmod +x /bin/chard_gpusr

    sudo tee /usr/share/applications/gpu-screen-recorder.desktop >/dev/null <<'DESKTOP_EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=GPU Screen Recorder
Exec=chard_gpusr
Icon=gpu-screen-recorder
Terminal=false
StartupNotify=true
Categories=AudioVideo;Recorder;
DESKTOP_EOF

echo
sudo groupmod -g 27 video
echo "${CYAN}GPU Screen Recorder CLI usage:${RESET} /bin/chard_gpusrc -w XWAYLAND0 -s 1920x1080 -f 60 -o ~/recording.mp4"
echo "${CYAN}GPU Screen Recorder UI usage:${RESET} /bin/chard_gpusr"
echo
