#!/bin/bash
cd /tmp
sudo rm -rf /tmp/platform2 2>/dev/null
git clone --filter=blob:none --sparse https://chromium.googlesource.com/chromiumos/platform2 /tmp/platform2
cd /tmp/platform2
git sparse-checkout set vm_tools/sommelier
cd vm_tools/sommelier

CHROMEOS_VERSION="$(cat "/.chard_chrome" 2>/dev/null | tr -d '[:space:]')"
if [ -n "$CHROMEOS_VERSION" ] && [ "$CHROMEOS_VERSION" -ge 145 ] && \
   [ "$(uname -m)" = "aarch64" ]; then
    echo "Applying Exo Color Inversion Patch (aarch64, ChromeOS 145+)..."
    python3 << 'EOF'
with open("/tmp/platform2/vm_tools/sommelier/compositor/sommelier-shm.cc", "r") as f:
    content = f.read()
old = """    sl_create_host_buffer(host->shm->ctx, client, id,
                          wl_shm_pool_create_buffer(host->proxy, offset, width,
                                                    height, stride, format),
                          width, height, /*is_drm=*/true);
    return;"""
new = """#if defined(__aarch64__)
    if (format == WL_SHM_FORMAT_XRGB8888) format = WL_SHM_FORMAT_ARGB8888;
#endif
    sl_create_host_buffer(host->shm->ctx, client, id,
                          wl_shm_pool_create_buffer(host->proxy, offset, width,
                                                    height, stride, format),
                          width, height, /*is_drm=*/true);
    return;"""
if old in content:
    content = content.replace(old, new)
    with open("/tmp/platform2/vm_tools/sommelier/compositor/sommelier-shm.cc", "w") as f:
        f.write(content)
    print("WL_SHM_FORMAT_XRGB8888 swapped with WL_SHM_FORMAT_ARGB8888")
else:
    print("WL_SHM_FORMAT_XRGB8888 unchanged")
EOF
else
    echo "Skipping Exo Color Inversion Patch."
fi

echo "Applying arc.session patch..."
python3 << 'EOF'
with open("/tmp/platform2/vm_tools/sommelier/sommelier-window.cc", "r") as f:
    content = f.read()
old = """  if (ctx->application_id) {
    zaura_surface_set_application_id(window->aura_surface, ctx->application_id);
    return;
  }"""
new = """  if (ctx->application_id) {
    // Calling arc.session authorizes pointer capture in Exo.
    // Falling through allows WM_CLASS ID to overwrite for shelf icon resolution.
    if (strstr(ctx->application_id, "arc.session") != nullptr) {
      zaura_surface_set_application_id(window->aura_surface, ctx->application_id);
    } else {
      zaura_surface_set_application_id(window->aura_surface, ctx->application_id);
      return;
    }
  }"""
if old in content:
    content = content.replace(old, new)
    with open("/tmp/platform2/vm_tools/sommelier/sommelier-window.cc", "w") as f:
        f.write(content)
    print("arc.session shelf icon patch applied")
else:
    print("Patch not applied")
EOF

python3 << 'EOF'
with open("/tmp/platform2/vm_tools/sommelier/sommelier-window.cc", "r") as f:
    content = f.read()

old = """  if (ctx->aura_shell) {
    uint32_t frame_color;

    if (!window->aura_surface) {
      window->aura_surface = zaura_shell_get_aura_surface(
          ctx->aura_shell->internal, host_surface->proxy);
    }

    zaura_surface_set_frame(window->aura_surface,
                            window->decorated ? ZAURA_SURFACE_FRAME_TYPE_NORMAL
                            : window->depth == 32
                                ? ZAURA_SURFACE_FRAME_TYPE_NONE
                                : ZAURA_SURFACE_FRAME_TYPE_SHADOW);

    frame_color = window->dark_frame ? ctx->dark_frame_color : ctx->frame_color;
    zaura_surface_set_frame_colors(window->aura_surface, frame_color,
                                   frame_color);
    zaura_surface_set_startup_id(window->aura_surface, window->startup_id);
    sl_update_application_id(ctx, window);

    if (ctx->aura_shell->version >=
        ZAURA_SURFACE_SET_FULLSCREEN_MODE_SINCE_VERSION) {
      zaura_surface_set_fullscreen_mode(window->aura_surface,
                                        ctx->fullscreen_mode);
    }
  }"""

new = """  if (ctx->aura_shell) {
    uint32_t frame_color;

    if (!window->aura_surface) {
      // Chard: skip aura_surface for override-redirect (unmanaged) windows
      // under arc.session — Exo immediately destroys any override-redirect
      // popup/menu that has an aura_surface (VLC, Qt, Brave, Steam etc).
      bool skip_aura = !window->managed && ctx->application_id &&
                       strstr(ctx->application_id, "arc.session") != nullptr;
      if (!skip_aura) {
        window->aura_surface = zaura_shell_get_aura_surface(
            ctx->aura_shell->internal, host_surface->proxy);
      }
    }

    if (window->aura_surface) {
      zaura_surface_set_frame(window->aura_surface,
                              window->decorated ? ZAURA_SURFACE_FRAME_TYPE_NORMAL
                              : window->depth == 32
                                  ? ZAURA_SURFACE_FRAME_TYPE_NONE
                                  : ZAURA_SURFACE_FRAME_TYPE_SHADOW);

      frame_color = window->dark_frame ? ctx->dark_frame_color : ctx->frame_color;
      zaura_surface_set_frame_colors(window->aura_surface, frame_color,
                                     frame_color);
      zaura_surface_set_startup_id(window->aura_surface, window->startup_id);
      sl_update_application_id(ctx, window);

      if (ctx->aura_shell->version >=
          ZAURA_SURFACE_SET_FULLSCREEN_MODE_SINCE_VERSION) {
        zaura_surface_set_fullscreen_mode(window->aura_surface,
                                          ctx->fullscreen_mode);
      }
    }
  }"""

if old in content:
    content = content.replace(old, new)
    print("aura_surface block guarded ✓")
else:
    print("block pattern not found ✗")

old = """  if ((window->size_flags & (US_POSITION | P_POSITION)) && parent &&
      ctx->aura_shell) {
    int32_t diffx = window->x - parent->x;
    int32_t diffy = window->y - parent->y;

    sl_transform_guest_to_host(window->ctx, window->paired_surface, &diffx,
                               &diffy);
    zaura_surface_set_parent(window->aura_surface, parent->aura_surface, diffx,
                             diffy);
  }"""

new = """  if ((window->size_flags & (US_POSITION | P_POSITION)) && parent &&
      ctx->aura_shell && window->aura_surface && parent->aura_surface) {
    int32_t diffx = window->x - parent->x;
    int32_t diffy = window->y - parent->y;

    sl_transform_guest_to_host(window->ctx, window->paired_surface, &diffx,
                               &diffy);
    zaura_surface_set_parent(window->aura_surface, parent->aura_surface, diffx,
                             diffy);
  }"""

if old in content:
    content = content.replace(old, new)
    print("Patched zaura_surface_set_parent null guard")
else:
    print("set_parent pattern not found")

with open("/tmp/platform2/vm_tools/sommelier/sommelier-window.cc", "w") as f:
    f.write(content)
EOF

meson setup build
ninja -C build
sudo -E ninja -C build install
cd /tmp
sudo rm -rf /tmp/platform2 2>/dev/null
