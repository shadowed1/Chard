# Chard (Chrome-Arch Development)
## Goal: Run any Linux program/app natively in ChromeOS in a semi-sandboxed environment in /usr/local/chard <br>
### Please do not install without a usb recovery as this is under rapid development and mistakes happen.<br>
*Requires Developer Mode* <br>
*Untested with Brunch Toolchain, Chromebrew, and dev_install* <br>
*After install, chard commands will be available, along with many apps; like nano.* <br>
`nano` <--- to launch nano. <br>
`gcc` <br>
`python` <br>
`chard emerge` <--- prepend chard to command of your choice to have a custom wrapper only use paths in `/usr/local/chard` <br>
`Et Al` <br>

Chard appends its paths to ChromeOS, ensuring it never overrides system commands. <br> <br>

To install, open up crosh, type in shell: <br>

<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/chard_download?$(date +%s)")</pre>

Gentoo Linux /bin
make 
gmp
mpfr
binutils
diffutils
openssl
git
coreutils
perl
Capture-Tiny
Try-Tiny
Config-AutoConf
Test-Fatal
findutils
python
meson
glib
pkg-config
gtest
re2c
ninja
docbook
gtk-doc
zlib
bash-completion
sqlite
util-linux
libffi
freetype
graphite2
Locale-gettext
pcre2
libpng
fontconfig
pixman
icu
chafa
lzo
cairo
harfbuzz
texinfo
libseccomp
libunistring
file
extra-cmake-modules
File-LibMagic
portage
util-macros
smartmontools
xorgproto
xtrans
xcb-proto
libxcb
xextproto
libX11
libXext
libXrender
libXfixes
libXi
libXcursor
libXrandr
libXinerama
libdrm
libglvnd
libvdpau
glslang
mesa
glu
libsndfile
libtool
fftw
libasyncns
tdb
check
pulseaudio
json-glib
bubblewrap
libcap
libarchive
gpgme
libiconv
fuse
libostree
libpsl
curl
expat
duktape
p11-kit
gvdb
gobject-introspection
libXau
sphinx
graphviz
vala
dconf
gsettings-desktop-schemas
shared-mime-info
rust
glycin
gdk-pixbuf
appstream-glib
flatpak
polkit
polkit-kde-agent
malcontent
sysprof
libxau
qt6-base
qt6-tools
