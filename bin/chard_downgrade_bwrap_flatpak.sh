cd ~/
sudo rm -rf /usr/local/bubblepatch
rm -rf bubblepatch 2>/dev/null
git clone https://github.com/shadowed1/bubblepatch.git
cd bubblepatch
sudo mkdir -p /usr/local/bubblepatch

meson setup \
  -Dprefix=/usr/local/bubblepatch \
  -Drequire_userns=false \
  -Dselinux=disabled \
  -Dtests=false \
  -Dbash_completion=disabled \
  -Dzsh_completion=disabled \
  -Dman=disabled \
  build

ninja -C build
sudo ninja -C build install
cd ~/
sudo rm -rf bubblepatch

sudo mkdir -p /usr/local/bwrap-0.11
wget -c -P /tmp https://github.com/containers/bubblewrap/releases/download/v0.11.1/bubblewrap-0.11.1.tar.xz
tar -xf /tmp/bubblewrap-0.11.1.tar.xz -C /tmp
cd /tmp/bubblewrap-0.11.1
meson setup build -Dprefix=/usr/local/bwrap-0.11

meson setup \
  -Dprefix=/usr/local/bwrap-0.11 \
  -Drequire_userns=false \
  -Dselinux=disabled \
  -Dtests=false \
  -Dbash_completion=disabled \
  -Dzsh_completion=disabled \
  -Dman=disabled \
  build
  
ninja -C build
sudo ninja -C build install
cd
sudo rm -rf /tmp/bubblewrap-* 2>/dev/null


sudo mkdir -p /usr/local/flatpak-1.16.3
sudo rm -rf /tmp/flatpak-* 2>/dev/null
wget -c -P /tmp https://github.com/flatpak/flatpak/releases/download/1.16.3/flatpak-1.16.3.tar.xz
sudo tar -xf /tmp/flatpak-1.16.3.tar.xz -C /tmp
cd /tmp/flatpak-1.16.3
sed -i '69d' /tmp/flatpak-1.16.3/common/flatpak-exports.c
meson setup builddir \
  --prefix=/usr/local/flatpak-1.16.3 \
  --libdir=/usr/lib \
  -Dsystem_bubblewrap=/usr/local/bubblepatch/bin/bwrap \
  -Dsystem_dbus_proxy=/usr/bin/xdg-dbus-proxy \
  -Dsystem_helper=disabled \
  -Dsandboxed_triggers=false \
  -Dselinux_module=disabled \
  -Dmalcontent=disabled \
  -Dseccomp=disabled \
  -Dgir=disabled \
  -Dgtkdoc=disabled \
  -Ddocbook_docs=disabled \
  -Dman=disabled \
  -Dtests=false \
  -Dinstalled_tests=false \
  -Dauto_sideloading=false \
  -Dgdm_env_file=false \
  -Dsystemd=disabled \
  -Ddconf=disabled \
  -Dxauth=disabled \
  -Dwayland_security_context=disabled \
  -Dinternal_checks=false
  
ninja -C builddir -j$(nproc)
sudo ninja -C builddir install
cd
sudo rm -rf /tmp/flatpak-* 2>/dev/null
sudo pacman -S flatpak --noconfirm --overwrite '*' 2>/dev/null
/usr/local/flatpak-1.16.3/bin/flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo chown -R 1000:1000 ~/.local/share/flatpak 2>/dev/null
sudo chown -R 1000:1000 /usr/local/flatpak-1.16.3/var/lib/flatpak/exports/share 2>/dev/null
