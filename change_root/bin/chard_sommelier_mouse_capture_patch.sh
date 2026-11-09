#!/bin/bash
cd /tmp
sudo rm -rf /tmp/platform2 2>/dev/null
git clone --filter=blob:none --sparse https://chromium.googlesource.com/chromiumos/platform2 /tmp/platform2
cd /tmp/platform2
git sparse-checkout set vm_tools/sommelier
cd vm_tools/sommelier
python3 << 'EOF'
with open("/tmp/platform2/vm_tools/sommelier/sommelier-window.cc", "r") as f:
    content = f.read()
old = """  if (ctx->application_id) {
    zaura_surface_set_application_id(window->aura_surface, ctx->application_id);
    return;
  }"""
new = """  if (ctx->application_id) {
    // Calling arc.session authorizes pointer
    // Obtaining WM_CLASS prior to calling zaura_surface_set_application_id
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
    print("arc.session patched")
else:
    print("Line not found, patch not applied")
EOF
meson setup build
ninja -C build
sudo -E ninja -C build install
cd /tmp
sudo rm -rf /tmp/platform2 2>/dev/null
