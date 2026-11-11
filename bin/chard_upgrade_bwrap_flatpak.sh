# Not working for me 
cd

sudo pacman -Rdd --noconfirm bubblewrap 2>/dev/null
sudo sed -i 's/^IgnorePkg   = bubblewrap flatpak$/#IgnorePkg   =/' /etc/pacman.conf 2>/dev/null
rm -rf ~/pkgbuilds/bubblewrap-local 2>/dev/null
sudo rm -rf /usr/local/bubblepatch 2>/dev/null
sudo rm -rf /usr/local/bwrap-0.11* 2>/dev/null
sudo rm -rf /usr/local/flatpak-1.16.3 2>/dev/null

rm -rf bubblewrap-0.13.0 2>/dev/null
curl -fsSLO https://github.com/containers/bubblewrap/releases/download/v0.13.0/bubblewrap-0.13.0.tar.xz
tar -xf bubblewrap-0.13.0.tar.xz
cd bubblewrap-0.13.0
curl -fsSL "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/bubblewrap-0.13.2.patch" -o "$HOME/bubblewrap-0.13.0/bubblewrap-0.13.2.patch" 2>/dev/null
patch --batch --fuzz=0 -p1 < bubblewrap-0.13.2.patch

meson setup \
  -Dprefix=/usr \
  -Dselinux=disabled \
  -Dtests=false \
  -Dbash_completion=disabled \
  -Dzsh_completion=disabled \
  -Dman=disabled \
  build

ninja -C build
sudo ninja -C build install

cd
rm -rf bubblewrap-0.13.0 2>/dev/null
rm -rf bubblewrap-0.13.0.tar.xz 2>/dev/null


##################################################################################################
sudo pacman -S --noconfirm flatpak --overwrite '*' 2>/dev/null
FEATURES="-protect-owned -collision-protect" sudo emerge -1 sys-apps/flatpak 2>/dev/null
/usr/bin/flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo chown -R 1000:1000 ~/.local/share/flatpak 2>/dev/null
sudo chown -R 1000:1000 /usr/local/flatpak-1.16.3/var/lib/flatpak/exports/share 2>/dev/null
