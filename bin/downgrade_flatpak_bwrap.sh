cd
sudo rm -rf /tmp/bubblewrap-* 2>/dev/null
wget -c -P /tmp https://github.com/containers/bubblewrap/releases/download/v0.11.1/bubblewrap-0.11.1.tar.xz
tar -xf /tmp/bubblewrap-0.11.1.tar.xz -C /tmp
cd /tmp/bubblewrap-0.11.1
meson setup build -Dprefix=/usr
ninja -C build
sudo ninja -C build install
cd
sudo rm -rf /tmp/bubblewrap-* 2>/dev/null
#!/bin/bash

cd
sudo rm -rf /tmp/flatpak-* 2>/dev/null
wget -c -P /tmp https://github.com/flatpak/flatpak/releases/download/1.16.3/flatpak-1.16.3.tar.xz
tar -xf /tmp/flatpak-1.16.3.tar.xz -C /tmp
cd /tmp/flatpak-1.16.3
meson setup builddir \
  --prefix=/usr \
  --libdir=/usr/lib \
  -Dsystem_bubblewrap=/usr/local/bubblepatch/bin/bwrap \
  -Dsystem_helper=disabled \
  -Dsandboxed_triggers=false \
  -Dselinux_module=disabled \
  -Dmalcontent=disabled \
  -Dgir=disabled \
  -Dgtkdoc=disabled \
  -Ddocbook_docs=disabled \
  -Dman=disabled \
  -Dtests=false \
  -Dinstalled_tests=false \
  -Dauto_sideloading=false \
  -Dgdm_env_file=false
      
ninja -C builddir -j$(nproc)
sudo ninja -C builddir install
cd
sudo rm -rf /tmp/flatpak-* 2>/dev/null
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo chown -R 1000:1000 ~/.local/share/flatpak 2>/dev/null
