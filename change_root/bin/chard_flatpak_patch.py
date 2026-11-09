#!/usr/bin/env python3
"""
Flatpak 1.16.3 enabled with setuid bwrap (ChromeOS has no
unprivileged user namespaces, so bwrap must run setuid).
"""

import sys, re

EDITS = [
    (
        "common/flatpak-context.c",
        """          g_autofree char *src_via_proc = g_strdup_printf ("%d", src_fd);

          flatpak_bwrap_add_fd (bwrap, g_steal_fd (&src_fd));
          flatpak_bwrap_add_bind_arg (bwrap, "--bind-fd", src_via_proc, dest);""",
        """          /* Chard: bwrap runs setuid here (ChromeOS refuses unprivileged
           * user namespaces), and in setuid mode the bind source is remapped
           * below /oldroot. The kernel cannot mount from
           * "/oldroot/proc/self/fd/N", so fd-backed binds never work in that
           * configuration. The symlink check above already rejected the
           * unsafe cases, so a plain path bind is equivalent here. */
          (void) glnx_close_fd (&src_fd);

          g_autofree char *src_path = g_build_filename (appdir, persist, NULL);

          flatpak_bwrap_add_bind_arg (bwrap, "--bind", src_path, dest);""",
    ),
    (
        "common/flatpak-run-cups.c",
        """  flatpak_bwrap_add_args (bwrap,
                          "--ro-bind", cups_server_name, sandbox_server_name,
                          NULL);""",
        """  /* Chard: in setuid-bwrap mode (ChromeOS has no unprivileged user
   * namespaces) a destination reached through a symlink that crosses a
   * mount point - /var/run -> ../run - fails with ELOOP. add_bind_arg()
   * realpath-resolves the destination, which lands it on /run/... instead. */
  flatpak_bwrap_add_bind_arg (bwrap, "--ro-bind", cups_server_name,
                              sandbox_server_name);""",
    ),
    (
        "common/flatpak-run-dbus.c",
        """  else if (g_file_test ("/var/run/dbus/system_bus_socket", G_FILE_TEST_EXISTS))
    dbus_system_socket = g_strdup ("/var/run/dbus/system_bus_socket");""",
        """  else if (g_file_test ("/var/run/dbus/system_bus_socket", G_FILE_TEST_EXISTS))
    {
      /* Chard: resolve through the /var/run symlink up front - in setuid
       * bwrap mode a source path that crosses a mount point via a symlink
       * cannot be mounted. */
      dbus_system_socket = realpath ("/var/run/dbus/system_bus_socket", NULL);
      if (dbus_system_socket == NULL)
        dbus_system_socket = g_strdup ("/var/run/dbus/system_bus_socket");
    }""",
    ),
]


def main(root):
    failed = []
    for path, before, after in EDITS:
        p = root.rstrip("/") + "/" + path
        with open(p, "r", encoding="utf-8") as f:
            text = f.read()
        if after in text:
            print(f"already applied: {path}")
            continue
        if before not in text:
            failed.append(path)
            print(f"NO MATCH (upstream changed?): {path}")
            continue
        n = text.count(before)
        text = text.replace(before, after)
        with open(p, "w", encoding="utf-8") as f:
            f.write(text)
        print(f"patched {path} ({n} site(s))")
    if failed:
        return 1
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
