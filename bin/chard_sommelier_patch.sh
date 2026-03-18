#!/bin/bash
cd /tmp
sudo rm -rf /tmp/platform2 2>/dev/null
git clone --filter=blob:none --sparse https://chromium.googlesource.com/chromiumos/platform2 /tmp/platform2
cd /tmp/platform2
git sparse-checkout set vm_tools/sommelier
cd vm_tools/sommelier

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
    print("WL_SHM_FORMAT_XRGB8888 swapped with WL_SHM_FORMAT_ARGB8888 ")
else:
    print("WL_SHM_FORMAT_XRGB8888 unchanged. ")
EOF

meson setup build
ninja -C build
sudo -E ninja -C build install
cd /tmp
sudo rm -rf /tmp/platform2 2>/dev/null
