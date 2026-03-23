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
    print("Color inversion patch applied")
else:
    print("Color inversion patch not applied")
EOF
else
    echo "Skipping Exo Color Inversion Patch."
fi

echo "Applying arc.session + unmanaged popup fix patches..."
python3 << 'EOF'
results = []

with open("/tmp/platform2/vm_tools/sommelier/sommelier-window.cc", "r") as f:
    content = f.read()

old = """  if (ctx->application_id) {
    zaura_surface_set_application_id(window->aura_surface, ctx->application_id);
    return;
  }"""
new = """  if (ctx->application_id) {
    if (strstr(ctx->application_id, "arc.session") != nullptr) {
      zaura_surface_set_application_id(window->aura_surface, ctx->application_id);
    } else {
      zaura_surface_set_application_id(window->aura_surface, ctx->application_id);
      return;
    }
  }"""
if old in content:
    content = content.replace(old, new)
    results.append("arc.session shelf icon patch")
else:
    results.append("arc.session shelf icon patch")

old = """    zaura_surface_set_startup_id(window->aura_surface, window->startup_id);
    sl_update_application_id(ctx, window);"""
new = """    zaura_surface_set_startup_id(window->aura_surface, window->startup_id);
    if (window->managed || !ctx->application_id ||
        strstr(ctx->application_id, "arc.session") == nullptr) {
      sl_update_application_id(ctx, window);
    }"""
if old in content:
    content = content.replace(old, new)
    results.append("Patched unmanaged popup application_id guard")
else:
    results.append("popup application_id not found")

with open("/tmp/platform2/vm_tools/sommelier/sommelier-window.cc", "w") as f:
    f.write(content)

for r in results:
    print(r)
EOF

meson setup build
ninja -C build
sudo -E ninja -C build install
cd /tmp
sudo rm -rf /tmp/platform2 2>/dev/null
