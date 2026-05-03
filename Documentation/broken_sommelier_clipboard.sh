#!/bin/bash
cd /tmp
sudo rm -rf /tmp/chardonnay 2>/dev/null
git clone https://github.com/shadowed1/chardonnay.git /tmp/chardonnay
cd /tmp/chardonnay/platform2/vm_tools/sommelier

CHROMEOS_VERSION="$(cat "/.chard_chrome" 2>/dev/null | tr -d '[:space:]')"
if [ -n "$CHROMEOS_VERSION" ] && [ "$CHROMEOS_VERSION" -ge 145 ] && \
   [ "$(uname -m)" = "aarch64" ]; then
    echo "Applying Exo Color Inversion Patch (aarch64, ChromeOS 145+)..."
    python3 << 'EOF'
with open("/tmp/chardonnay/platform2/vm_tools/sommelier/compositor/sommelier-shm.cc", "r") as f:
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
    with open("/tmp/chardonnay/platform2/vm_tools/sommelier/compositor/sommelier-shm.cc", "w") as f:
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

with open("/tmp/chardonnay/platform2/vm_tools/sommelier/sommelier-window.cc", "r") as f:
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

with open("/tmp/chardonnay/platform2/vm_tools/sommelier/sommelier-window.cc", "w") as f:
    f.write(content)

for r in results:
    print(r)
EOF

echo "Applying patch: Adding selection_x11_source_atoms to sl_context"
python3 << 'EOF'
results = []

path = "sommelier-ctx.h"

with open(path, "r") as f:
    content = f.read()

anchor = "  int selection_data_ack_pending;"

new_field = "  struct wl_array selection_x11_source_atoms;

if new_field in content:
    results.append("Patch 1 already applied")
elif anchor in content:
    content = content.replace(anchor, anchor + "\n" + new_field)
    results.append("Patch 1 applied: selection_x11_source_atoms added to sl_context")
else:
    results.append(f"ERROR: Could not find patch site in {path}")

with open(path, "w") as f:
    f.write(content)

for r in results:
    print(r)
EOF

echo "Applying patch: Snapshot X11 atoms in sl_get_selection_targets..."
python3 << 'EOF'
results = []

path = "sommelier.cc"

with open(path, "r") as f:
    content = f.read()

anchor = "    value = static_cast<xcb_atom_t*>(xcb_get_property_value(reply));"

patch_code = """    value = static_cast<xcb_atom_t*>(xcb_get_property_value(reply));

wl_array_release(&ctx->selection_x11_source_atoms);
wl_array_init(&ctx->selection_x11_source_atoms);
if (reply->value_len > 0) {
  xcb_atom_t* snap = static_cast<xcb_atom_t*>(
      wl_array_add(&ctx->selection_x11_source_atoms,
                   sizeof(xcb_atom_t) * reply->value_len));
  memcpy(snap, value, sizeof(xcb_atom_t) * reply->value_len);
}
"""

if patch_code in content:
    results.append("Patch 2 already applied")
elif anchor in content:
    content = content.replace(anchor, patch_code)
    results.append("Patch 2 applied: X11 atoms snapshot added in sl_get_selection_targets")
else:
    results.append(f"ERROR: Could not find patch site in {path}")

with open(path, "w") as f:
    f.write(content)

for r in results:
    print(r)
EOF

echo "Applying patch: Merge saved X11 atoms into data_offer..."
python3 << 'EOF'
results = []

path = "sommelier.cc"

with open(path, "r") as f:
    content = f.read()

anchor = "    xcb_set_selection_owner(ctx->connection, ctx->selection_window,\n" \
         "                            ctx->atoms[ATOM_CLIPBOARD].value, XCB_CURRENT_TIME);"

patch_code = """    
    if (ctx->selection_x11_source_atoms.size > 0) {
      int n_x11 = ctx->selection_x11_source_atoms.size / sizeof(xcb_atom_t);
      xcb_atom_t* x11_atoms =
          static_cast<xcb_atom_t*>(ctx->selection_x11_source_atoms.data);
      for (int j = 0; j < n_x11; j++) {
        xcb_atom_t candidate = x11_atoms[j];
        bool already_present = false;
        xcb_atom_t* existing;
        sl_array_for_each(existing, &data_offer->atoms) {
          if (*existing == candidate) {
            already_present = true;
            break;
          }
        }
        if (!already_present) {
          xcb_atom_t* slot = static_cast<xcb_atom_t*>(
              wl_array_add(&data_offer->atoms, sizeof(xcb_atom_t)));
          *slot = candidate;
        }
      }
    }

    xcb_set_selection_owner(ctx->connection, ctx->selection_window,
                            ctx->atoms[ATOM_CLIPBOARD].value, XCB_CURRENT_TIME);"""

if patch_code in content:
    results.append("Patch 3 already applied")
elif anchor in content:
    content = content.replace(anchor, patch_code)
    results.append("Patch 3 applied: merged X11 atoms before stealing clipboard")
else:
    results.append(f"ERROR: Could not find patch site in {path}")

with open(path, "w") as f:
    f.write(content)

for r in results:
    print(r)
EOF

echo "Applying patch: Add file clipboard roundtrip storage"
python3 << 'EOF'
results = []

path = "sommelier-ctx.h"

with open(path, "r") as f:
    content = f.read()

anchor = "  struct wl_array selection_x11_source_atoms;

new_field = """
  struct {
      void* data;
      size_t size;
  } selection_x11_file_targets[2];"""

if new_field in content:
    results.append("Patch 4 already applied")
elif anchor in content:
    content = content.replace(anchor, anchor + "\n" + new_field)
    results.append("Patch 4 applied: file clipboard storage added to sl_context")
else:
    results.append(f"ERROR: Could not find patch site in {path}")

with open(path, "w") as f:
    f.write(content)

for r in results:
    print(r)
EOF

echo "Applying patch: Inject Wayland file MIME types"
python3 << 'EOF'
results = []

path = "sommelier.cc"

with open(path, "r") as f:
    content = f.read()

anchor = "    int atoms = data_offer->cookies.size / sizeof(xcb_intern_atom_cookie_t);"

patch_code = """
    {
        const char* extra_types[] = {
            "text/uri-list",
            "x-special/gnome-copied-files"
        };

        for (size_t k = 0; k < sizeof(extra_types)/sizeof(extra_types[0]); k++) {
            xcb_intern_atom_cookie_t* cookie =
                static_cast<xcb_intern_atom_cookie_t*>(
                    wl_array_add(&data_offer->cookies,
                                 sizeof(xcb_intern_atom_cookie_t)));
            *cookie = xcb_intern_atom(ctx->connection, 0,
                                     strlen(extra_types[k]),
                                     extra_types[k]);
        }
    }

    int atoms = data_offer->cookies.size / sizeof(xcb_intern_atom_cookie_t);"""

if patch_code in content:
    results.append("Patch 5 already applied")
elif anchor in content:
    content = content.replace(anchor, patch_code)
    results.append("Patch 5 applied (fixed)")
else:
    results.append("ERROR: Could not find patch site in sommelier.cc")

with open(path, "w") as f:
    f.write(content)

for r in results:
    print(r)
EOF


python3 << 'EOF'
path = "sommelier.cc"

with open(path, "r") as f:
    content = f.read()

helper = r"""
static char* sl_rewrite_file_uris(const char* buf, size_t len, size_t* out_len) {
  static char chard_root[256] = "";
  if (chard_root[0] == '\0') {
    const char* env = getenv("CHARD_ROOT");
    if (env && env[0] != '\0') {
      strncpy(chard_root, env, sizeof(chard_root) - 1);
    } else {
      FILE* fp = fopen("/.install_path", "r");
      if (fp) {
        if (fgets(chard_root, sizeof(chard_root), fp)) {
          size_t n = strlen(chard_root);
          while (n > 0 && (chard_root[n-1] == '\n' || chard_root[n-1] == '\r' ||
                           chard_root[n-1] == ' '))
            chard_root[--n] = '\0';
        }
        fclose(fp);
      }
    }
    if (chard_root[0] == '\0')
      strncpy(chard_root, "/CHARD_NONE", sizeof(chard_root) - 1);
  }

  if (strcmp(chard_root, "/CHARD_NONE") == 0) return NULL;

  const char* needle = "file:///";
  size_t nlen = 8;
  if (!memmem(buf, len, needle, nlen)) return NULL;

  char replacement[300];
  int rlen = snprintf(replacement, sizeof(replacement), "file://%s/", chard_root);
  if (rlen <= 0 || rlen >= (int)sizeof(replacement)) return NULL;

  int count = 0;
  const char* p = buf;
  while ((p = (const char*)memmem(p, (size_t)(buf + len - p), needle, nlen)) != NULL) {
    count++;
    p += nlen;
  }
  if (count == 0) return NULL;

  size_t new_len = len + (size_t)count * ((size_t)rlen - nlen);
  char* out = static_cast<char*>(malloc(new_len + 1));
  if (!out) return NULL;

  char* dst = out;
  const char* src = buf;
  const char* end = buf + len;
  while (src < end) {
    const char* found = (const char*)memmem(src, (size_t)(end - src), needle, nlen);
    if (!found) {
      memcpy(dst, src, (size_t)(end - src));
      dst += end - src;
      break;
    }
    memcpy(dst, src, (size_t)(found - src));
    dst += found - src;
    memcpy(dst, replacement, (size_t)rlen);
    dst += rlen;
    src = found + nlen;
  }
  *out_len = new_len;
  return out;
}

"""

anchor = "static int sl_handle_selection_fd_writable(int fd, uint32_t mask, void* data) {"

if "sl_rewrite_file_uris" in content:
    print("Patch already applied")
elif anchor in content:
    content = content.replace(anchor, helper + anchor)
    with open(path, "w") as f:
        f.write(content)
    print("Patch applied: sl_rewrite_file_uris helper inserted")
else:
    print("ERROR: anchor not found for patch)
EOF

python3 << 'EOF'
path = "sommelier.cc"

with open(path, "r") as f:
    content = f.read()

old = "bytes = write(fd, value + ctx->selection_property_offset, bytes_left);"

replacement = """\
  {
    const uint8_t* src = value + ctx->selection_property_offset;

    size_t rewritten_len = 0;
    char* rewritten = sl_rewrite_file_uris(
        (const char*)src,
        (size_t)bytes_left,
        &rewritten_len);

    const uint8_t* write_buf = src;
    size_t write_len = (size_t)bytes_left;

    if (rewritten) {
      write_buf = (const uint8_t*)rewritten;

      if (rewritten_len < write_len)
        write_len = rewritten_len;
    }

    bytes = write(fd, write_buf, write_len);

    if (rewritten)
      free(rewritten);

    if (bytes > 0)
      ctx->selection_property_offset += bytes;
  }"""

if replacement in content:
    print("Patch already applied")
elif old in content:
    content = content.replace(old, replacement, 1)
    with open(path, "w") as f:
        f.write(content)
    print("Patch applied successfully")
else:
    print("ERROR: write() anchor not found")
EOF

meson setup build
ninja -C build
sudo -E ninja -C build install
cd /tmp
sudo rm -rf /tmp/chardonnay 2>/dev/null
