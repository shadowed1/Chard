# CHARD .BASHRC

ARCH=$(uname -m)
case "$ARCH" in
    x86_64) CHOST=x86_64-pc-linux-gnu ;;
    aarch64) CHOST=aarch64-unknown-linux-gnu ;;
    *) echo "Unknown architecture: $ARCH"; exit 1 ;;
esac

DEFAULT_FEATURES="assume-digests binpkg-docompress binpkg-dostrip binpkg-logs config-protect-if-modified distlocks ebuild-locks fixlafiles ipc-sandbox merge-sync multilib-strict network-sandbox news parallel-fetch pid-sandbox preserve-libs protect-owned strict unknown-features-warn unmerge-logs unmerge-orphans userfetch userpriv usersync xattr"
export FEATURES="${FEATURES:-$DEFAULT_FEATURES}"
DEFAULT_USE="X a52 aac acl acpi alsa amd64 bindist branding bzip2 cairo cdda cdr cet clang crypt curl cups dbus dri dts dvd dvdr -elogind encode exif extra flac ffmpeg gdbm gif gles2 gpm gstreamer gtk gui iconv icu ipv6 jpeg lcms libnotify libtirpc llvm mad mng mp3 mp4 mpeg multilib ncurses networkmanager nls ogg opengl openmp openssl opus pam pango pcre pdf png policykit pipewire ppds pulseaudio qml qt5 qt6 readline sdl seccomp sound spell ssl startup-notification svg test-rust -tiff truetype udev udisks unicode upower usb verify-sig vorbis vulkan wayland webp wifi wxwidgets x264 xattr xcb xft xml xv xvid xwayland zlib python_targets_python3_13"
export USE="${USE:-$DEFAULT_USE}"

export ROOT="/"
export CHARD_RC="$ROOT/.chardrc"
export PORTDIR="$ROOT/usr/portage"
export DISTDIR="$ROOT/var/cache/distfiles"
export PKGDIR="$ROOT/var/cache/packages"
export PORTAGE_TMPDIR="$ROOT/var/tmp"
export SANDBOX="$ROOT/usr/bin/sandbox"
export GIT_EXEC_PATH="$ROOT/usr/libexec/git-core"
export PERL5LIB="$ROOT/lib/perl5/5.40.0:$PERL5LIB"
export PATH="$PATH:$ROOT/usr/bin:$ROOT/bin:$ROOT/usr/$CHOST/gcc-bin/14"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$ROOT/usr/lib:$ROOT/lib:$ROOT/usr/lib/gcc/$CHOST/14:$ROOT/usr/$CHOST/gcc-bin/14"
export PKG_CONFIG_PATH=//usr/lib/pkgconfig:/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig
export MAGIC="$ROOT/usr/share/misc/magic.mgc"
export PKG_CONFIG=$ROOT/usr/bin/pkg-config
export GIT_TEMPLATE_DIR=$ROOT/usr/share/git-core/templates
export CPPFLAGS="-I$ROOT/usr/include"
export PYTHON_TARGETS="python3_13"
export PYTHON_SINGLE_TARGET="python3_13"
export PYTHONPATH="$ROOT/usr/lib/python3.13/site-packages:$PYTHONPATH"

export CC="$ROOT/usr/bin/gcc"
export CXX="$ROOT/usr/bin/g++"
export AR="$ROOT/usr/bin/ar"
export NM="$ROOT/usr/bin/gcc-nm"
export RANLIB="$ROOT/usr/bin/gcc-ranlib"
export STRIP="$ROOT/usr/bin/strip"
export XDG_DATA_DIRS="/usr/share://usr/share"

export EMERGE_DEFAULT_OPTS="--quiet-build=y --jobs=$(nproc)"

export CFLAGS="-O2 -pipe -I$ROOT/usr/include -I$ROOT/include $CFLAGS"
export CXXFLAGS="-O2 -pipe -I$ROOT/usr/include -I$ROOT/include $CXXFLAGS"
export LDFLAGS="-L$ROOT/usr/lib -L$ROOT/lib $LDFLAGS"
export ACLOCAL_PATH="$ROOT/usr/share/aclocal:$ACLOCAL_PATH"
export M4PATH="$ROOT/usr/share/m4:$M4PATH"
export MANPATH="$ROOT/usr/share/man:$MANPATH"
export MAKEOPTS="-j$(($(($(grep MemTotal /proc/meminfo | awk '{print $2}') + 1024*1024 - 1)) / 1024 / 1024 / 2))"
export DISPLAY=":0"
export GDK_BACKEND="x11"
export CLUTTER_BACKEND="x11"
# <<< END CHARD .BASHRC >>>
