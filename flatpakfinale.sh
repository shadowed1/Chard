#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
set -euo pipefail
sudo mkdir -p /usr/local/chard/tmp/safe/gtest
sudo mkdir -p /usr/local/chard/usr/share/git-core/templates
sudo cp /etc/resolv.conf /usr/local/chard/etc/
CHARD_ROOT="/usr/local/chard"
BUILD_DIR="$CHARD_ROOT/var/tmp/build"
GCC_DIR="/usr/local/chard/usr/$CHOST/gcc-bin/14"
export PYTHON="/usr/local/chard/bin/python3"
export CC="$GCC_DIR/$CHOST-gcc"
export CXX="$GCC_DIR/$CHOST-g++"
export AR="$GCC_DIR/gcc-ar"
export RANLIB="$GCC_DIR/$CHOST-gcc-ranlib"
export PATH="$PATH:$GCC_DIR:/usr/local/chard/usr/bin"
export CXXFLAGS="$CFLAGS"
export AWK=/usr/bin/mawk
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/usr/lib64"
export MAKEFLAGS="-j$(nproc)"
export INSTALL_ROOT="/usr/local/chard"
export ACLOCAL_PATH="/usr/local/chard/usr/share/aclocal"
export PYTHONPATH="/usr/local/chard/usr/lib/python3.*/site-packages:$PYTHONPATH"
export PKG_CONFIG_PATH=/usr/local/chard/usr/lib64/pkgconfig:/usr/local/chard/usr/lib/pkgconfig
export CFLAGS="-I/usr/local/chard/usr/include $CFLAGS"
export LDFLAGS="-L/usr/local/chard/usr/lib64 -L/usr/local/chard/usr/lib $LDFLAGS"
export GIT_TEMPLATE_DIR=/usr/local/chard/usr/share/git-core/templates


MAX_RETRIES=5
RETRY_DELAY=10

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        GENTOO_ARCH="amd64"
        CHOST="x86_64-pc-linux-gnu"
        ARCH_PKGS=(
            #"https://archlinux.org/packages/extra/x86_64/polkit/download"
            #"https://archlinux.org/packages/extra/x86_64/polkit-kde-agent/download"
            #"https://archlinux.org/packages/extra/x86_64/malcontent/download"
            #"https://archlinux.org/packages/extra/x86_64/sysprof/download"
            #"https://archlinux.org/packages/extra/x86_64/libxau/download"
            #"https://archlinux.org/packages/extra/x86_64/qt6-base/download"
            #"https://archlinux.org/packages/extra/x86_64/qt6-tools/download"
            #"https://archlinux.org/packages/extra/x86_64/highway/download"
            #"https://archlinux.org/packages/extra/x86_64/libavif/download"
            #"https://archlinux.org/packages/extra/x86_64/libwebp/download"
            #"https://archlinux.org/packages/extra/x86_64/dav1d/download/"
            #"https://archlinux.org/packages/extra/x86_64/rav1e/download"
            #"https://archlinux.org/packages/extra/x86_64/svt-av1/download"
            #"https://archlinux.org/packages/extra/x86_64/aom/download"
            #"https://archlinux.org/packages/extra/x86_64/libjpeg-turbo/download/"
            #"https://archlinux.org/packages/extra/x86_64/libpng/download/"
            #"https://archlinux.org/packages/extra/x86_64/libxshmfence/download/"
            #"https://archlinux.org/packages/extra/x86_64/lm_sensors/download"
            #"https://archlinux.org/packages/extra/x86_64/spirv-tools/download"
            #"https://archlinux.org/packages/extra/x86_64/freeglut/download/"
            #"https://archlinux.org/packages/extra/x86_64/libxxf86vm/download/"
            #"https://archlinux.org/packages/extra/x86_64/giflib/download/"
            #"https://archlinux.org/packages/extra/x86_64/openexr/download/"
            #"https://archlinux.org/packages/extra/x86_64/benchmark/download/"

        )
        ;;
    aarch64|arm64)
        GENTOO_ARCH="arm64"
        CHOST="aarch64-unknown-linux-gnu"
        ARCH_PKGS=(
            "http://mirror.archlinuxarm.org/aarch64/extra/polkit-126-2-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/polkit-kde-agent-6.4.5-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/malcontent-0.13.1-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/sysprof-48.1-2-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/libxau-1.0.12-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/qt6-base-6.9.2-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/qt6-tools-6.9.2-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/highway-1.3.0-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/libavif-1.3.0-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/libwebp-1.6.0-2-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/dav1d-1.5.1-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/rav1e-0.7.1-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/av1an-0.4.2-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/aom-3.13.1-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/libjpeg-turbo-3.1.2-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/libpng-1.6.50-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/lm_sensors-1:3.6.2-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/spirv-tools-1:1.4.321.0-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/libxshmfence-1.3.3-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/freeglut-3.6.0-2-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/libxxf86vm-1.1.6-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/giflib-5.2.2-2-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/openexr-3.4.0-1-aarch64.pkg.tar.xz"
            "http://mirror.archlinuxarm.org/aarch64/extra/benchmark-1.9.4-1-aarch64.pkg.tar.xz"
        )
        ;;
    *)
        echo "${RED}[!] Unsupported architecture: $ARCH${RESET}"
        exit 1
        ;;
esac

for url in "${ARCH_PKGS[@]}"; do
    FILE_NAME=$(basename "$url")
    DEST="$CHARD_ROOT/$FILE_NAME"

    echo "${CYAN}[+] Downloading $url"
    attempt=1
    while true; do
        sudo curl -L --progress-bar -o "$DEST" "$url" && break
        echo "${RED}[!] Download failed for $FILE_NAME (attempt $attempt/$MAX_RETRIES), retrying in $RETRY_DELAY seconds..."
        (( attempt++ ))
        if (( attempt > MAX_RETRIES )); then
            echo "${BOLD}${RED}[!] Failed to download $FILE_NAME after $MAX_RETRIES attempts. Aborting.${RESET}"
            exit 1
        fi
        sleep $RETRY_DELAY
    done

    echo "${RESET}${YELLOW}[+] Extracting $url"
    case "$DEST" in
        *.zst)
            sudo tar --use-compress-program=unzstd -xf "$DEST" -C "$CHARD_ROOT"
            ;;
        *.xz)
            sudo tar -xJf "$DEST" -C "$CHARD_ROOT"
            ;;
        *.tar.gz|*.tgz)
            sudo tar -xzf "$DEST" -C "$CHARD_ROOT"
            ;;
        *)
            sudo tar -xf "$DEST" -C "$CHARD_ROOT"
            ;;
    esac
done

for pkg in "${PACKAGES[@]}"; do
    IFS="|" read -r NAME VERSION EXT URL DIR BUILDSYS <<< "$pkg"
    ARCHIVE="$NAME-$VERSION.$EXT"

    echo "${RESET}${GREEN}[+] Downloading $URL "

    attempt=1
    while true; do
        sudo curl -L --progress-bar -o "$BUILD_DIR/$ARCHIVE" "$URL" && break

        echo "${RED}[!] Download failed for $NAME-$VERSION (attempt $attempt/$MAX_RETRIES), retrying in $RETRY_DELAY seconds..."
        (( attempt++ ))

        if (( attempt > MAX_RETRIES )); then
            echo "${BOLD}${RED}[!] Failed to download $NAME-$VERSION after $MAX_RETRIES attempts. Aborting.${RESET}"
            exit 1
        fi
        sleep $RETRY_DELAY
    done

    echo "${RESET}${YELLOW}[+] Extracting $NAME-$VERSION"
    case "$EXT" in
        tar.gz|tgz)
            sudo tar -xzf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" \
                --checkpoint=.500 --checkpoint-action=echo="   extracted %u files"
            ;;
        tar.xz)
            sudo tar -xJf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" \
                --checkpoint=.500 --checkpoint-action=echo="   extracted %u files"
            ;;
        tar.bz2)
            sudo tar -xjf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" \
                --checkpoint=.500 --checkpoint-action=echo="   extracted %u files"
            ;;
        zip)
            sudo bsdtar -xf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR"
            ;;
        *)
            echo "Unknown archive format: $EXT"
    esac
done

PACKAGES=(
    #"openssl|3.5.2|tar.gz|https://github.com/openssl/openssl/releases/download/openssl-3.5.2/openssl-3.5.2.tar.gz|openssl-3.5.2|gnusslcore"
    #"curl|8.16.0|tar.gz|https://github.com/curl/curl/releases/download/curl-8_16_0/curl-8.16.0.tar.gz|curl-8.16.0|gnussl"
    #"git|2.51.0|tar.gz|https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.51.0.tar.gz|git-2.51.0|git"
    #"libheif|1.20.2|tar.gz|https://github.com/strukturag/libheif/releases/download/v1.20.2/libheif-1.20.2.tar.gz|libheif-1.20.2|cmakeG"
    #"brotli|1.1.0|tar.gz|https://github.com/google/brotli/archive/refs/tags/v1.1.0.tar.gz|brotli-1.1.0|python"
    #"libwebp|1.3.0|tar.gz|https://github.com/webmproject/libwebp/archive/refs/tags/v1.3.0.tar.gz|libwebp-1.3.0|webp"
    #"libavif|1.2.2|tar.gz|https://github.com/AOMediaCodec/libavif/archive/refs/tags/v1.2.2.tar.gz|libavif-1.2.2|avif"
    "libjxl|0.11.1|tar.gz|https://github.com/libjxl/libjxl/archive/refs/tags/v0.11.1.tar.gz|libjxl-0.11.1|cmakejxl"
    "glycin|2.0.0|tar.gz|https://gitlab.gnome.org/GNOME/glycin/-/archive/2.0.0/glycin-2.0.0.tar.gz|glycin-2.0.0|mesonrust"
    "gdk-pixbuf|2.44.1|tar.xz|https://download.gnome.org/sources/gdk-pixbuf/2.44/gdk-pixbuf-2.44.1.tar.xz|gdk-pixbuf-2.44.1|meson"
)

sudo mkdir -p "$BUILD_DIR"

for pkg in "${PACKAGES[@]}"; do
    IFS="|" read -r NAME VERSION EXT URL DIR BUILDSYS <<< "$pkg"
    ARCHIVE="$NAME-$VERSION.$EXT"

    echo "[+] Downloading $NAME-$VERSION"
    attempt=1
    until sudo curl -L --progress-bar -o "$BUILD_DIR/$ARCHIVE" "$URL"; do
        echo "[!] Download failed (attempt $attempt/$MAX_RETRIES)"
        (( attempt++ ))
        if (( attempt > MAX_RETRIES )); then
            echo "[!] Aborting download of $NAME-$VERSION"
            exit 1
        fi
        sleep $RETRY_DELAY
    done

    echo "[+] Extracting $NAME-$VERSION"
    case "$EXT" in
        tar.gz|tgz) sudo tar -xzf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" ;;
        tar.xz)     sudo tar -xJf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" ;;
        tar.bz2)    sudo tar -xjf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" ;;
        zip)        sudo bsdtar -xf "$BUILD_DIR/$ARCHIVE" -C "$BUILD_DIR" ;;
    esac
done

echo "${GREEN}[+] Mounting chroot${RESET}"
sudo cp /etc/resolv.conf "$CHARD_ROOT/etc/resolv.conf"
mountpoint -q "$CHARD_ROOT/proc"    || sudo mount -t proc proc "$CHARD_ROOT/proc"
mountpoint -q "$CHARD_ROOT/sys"     || sudo mount -t sysfs sys "$CHARD_ROOT/sys"
mountpoint -q "$CHARD_ROOT/dev"     || sudo mount --bind /dev "$CHARD_ROOT/dev"
mountpoint -q "$CHARD_ROOT/dev/shm" || sudo mount --bind /dev/shm "$CHARD_ROOT/dev/shm"
mountpoint -q "$CHARD_ROOT/etc/ssl" || sudo mount --bind /etc/ssl "$CHARD_ROOT/etc/ssl"

for pkg in "${PACKAGES[@]}"; do
    IFS="|" read -r NAME VERSION EXT URL DIR BUILDSYS <<< "$pkg"
    echo "${GREEN}[+] Building $NAME-$VERSION in chroot${RESET}"

sudo chroot "/usr/local/chard" /bin/bash -c '
DIR="'"$DIR"'"
BUILDSYS="'"$BUILDSYS"'"

cd /var/tmp/build/"$DIR" || { echo "Failed to cd into /var/tmp/build/$DIR"; exit 1; }

ARCH=$(uname -m)
case "$ARCH" in
    x86_64) CHOST=x86_64-pc-linux-gnu ;;
    aarch64) CHOST=aarch64-unknown-linux-gnu ;;
    *) echo "Unknown architecture: $ARCH"; exit 1 ;;
esac

   GCC_DIR=/usr/$CHOST/gcc-bin/14
    export HOME=/home/chronos/user
    export MAGIC="/usr/share/misc/magic.mgc"
    export CC=$GCC_DIR/$CHOST-gcc
    export CXX=$GCC_DIR/$CHOST-g++
    export AR=$GCC_DIR/gcc-ar
    export RANLIB=$GCC_DIR/$CHOST-gcc-ranlib
    export PATH=/usr/$CHOST/gcc-bin/14:/usr/bin:/bin:/usr/local/bin:$HOME/.cargo/bin:$PATH
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}/lib:/lib64:/usr/lib:/usr/lib64:$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib:/usr/local/lib:/usr/local/lib64:/usr/lib/gcc/$CHOST/14"
    export PERL5LIB=/usr/local/lib/perl5/site_perl/5.40.0:/usr/local/lib/perl5:$PERL5LIB
    export PKG_CONFIG=/usr/bin/pkg-config
    export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib64/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH
    export PYTHON="/bin/python3"
    export FORCE_UNSAFE_CONFIGURE=1
    export XDG_DATA_DIRS="/usr/share:/usr/local/share"
    export CFLAGS="-O2 -pipe -fPIC -I/usr/include"
    export CXXFLAGS="-O2 -pipe -fPIC -I/usr/include"
    export LDFLAGS="-L/usr/lib"
    export GI_TYPELIB_PATH=/usr/lib64/girepository-1.0:${GI_TYPELIB_PATH:-}
    export CARGO_HOME="$HOME/.cargo"
    export RUSTUP_HOME="$HOME/.rustup"
    export GIT_TEMPLATE_DIR=/usr/share/git-core/templates

case "$BUILDSYS" in
        gnu)
            ./configure --prefix=/usr
            make -j"$(nproc)"
            make install
            ;;
        git)
            ./configure --prefix=/usr --with-curl
            make -j"$(nproc)"
            make install
            ;;
        gnuqt)
            ./configure -prefix /usr \
                        -release \
                        -opensource -confirm-license \
                        -nomake examples -nomake tests \
                        -system-zlib \
                        -system-libjpeg -system-libpng \
                        -system-freetype \
                        -system-harfbuzz \
                        -system-pcre2
            make -j"$(nproc)"
            make install
            ;;
        glibcgnuOOS)
            cd /var/tmp/build
            mkdir -p build-glibc-2.42
            cd build-glibc-2.42
            ../glibc-2.42/configure --prefix=/usr \
                                    --disable-werror \
                                    --enable-kernel=5.4
            make -j"$(nproc)"
            make install
            ;;
        pythongnuOOS)
            cd /var/tmp/build
            mkdir -p build-Python-3.13.7
            cd build-Python-3.13.7
            ../Python-3.13.7/configure --prefix=/usr \
                                       --enable-optimizations \
                                       --with-lto
            make -j"$(nproc)"
            make install
            ;;
        perl)
            perl Makefile.PL INSTALL_BASE=/usr/local
            make
            make test || true
            make install
            ;;
        perl-core)
            sh Configure -des -Dprefix=/usr
            make -j"$(nproc)"
            make install
            ;;
        cmake)
            cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_GMOCK=OFF
            cmake --build build -j"$(nproc)"
            cmake --install build
            ;;
        cmakeGLS)
            cmake -S glslang -B build -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_GMOCK=OFF
            cmake --build build -j"$(nproc)"
            cmake --install build
            ;;
        cmakeG)
            cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_GMOCK=OFF
            cmake --build build -j"$(nproc)"
            cmake --install build
            ;;
        cmakejxl)
            cd /var/tmp/build/libjxl-0.11.1
            sh deps.sh
        
            mkdir -p build
            cd build
        
            cmake .. \
                -DCMAKE_INSTALL_PREFIX=/usr \
                -DJPEGXL_ENABLE_BENCHMARKS=OFF \
                -DJPEGXL_ENABLE_TOOLS=ON \
                -DJPEGXL_ENABLE_JPEG=OFF \
                -DCMAKE_POLICY_VERSION_MINIMUM=3.5
        
            make -j"$(nproc)"
            make install
            ;;
        cmakeOpenGL)
            cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DFEATURE_opengl=desktop
            cmake --build build -j"$(nproc)"
            cmake --install build
            ;;
        cmakegtest)
            cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_GMOCK=OFF
            cmake --build build -j"$(nproc)"
            cmake --install build
            ;;
        cmakeGhighway)
            cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_GMOCK=OFF
            cmake --build build -j"$(nproc)"
            cmake --install build
            ;;
        meson)
            meson setup build --prefix=/usr
            ninja -C build
            ninja -C build install
            ;;
        mesonrust)
            cd /var/tmp/build/"$DIR"
            meson setup build --prefix=/usr --buildtype=release --native-file=/mesonrust.ini -Drustc="$CARGO_HOME/bin/rustc" -Dcargo="$CARGO_HOME/bin/cargo"
            ninja -C build
            ninja -C build install
            ;;
        mesongvdb)
            cd /var/tmp/build/gvdb-main/gvdb-main
            meson setup build --prefix=/usr
            ninja -C build
            ninja -C build install
            ;;
        gtk-doc)
            cd /var/tmp/build/"$DIR"
            chmod +x autogen.sh
            ./autogen.sh --prefix=/usr
            make -j"$(nproc)"
            make install
            ;;
        python)
            cd /var/tmp/build/"$DIR"
            /usr/bin/python3.13 setup.py build
            /usr/bin/python3.13 setup.py install --prefix=/usr
            ;;
        pythonbuild)
            cd /var/tmp/build/"$DIR"
            /usr/bin/python3.13 -m pip install . --prefix=/usr
            ;;
        cmakepython)
            cd /var/tmp/build/"$DIR"
            cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/usr/local/chard/usr -DCMAKE_BUILD_TYPE=Release
            cmake --build build -j"$(nproc)"
            cmake --install build
            /usr/bin/python3.13 setup.py build
            /usr/bin/python3.13 setup.py install --prefix=/usr
            ;;
        libcap)
            make -j"$(nproc)" prefix=/usr
            make test || true
            make install prefix=/usr
            ;;
        icu)
            cd /var/tmp/build/icu/source/
            chmod +x runConfigureICU configure install-sh
            ./runConfigureICU Linux --prefix=/usr --disable-dependency-tracking
            make -j"$(nproc)"
            make install
            ;;
        gnussl)
            ./configure --prefix=/usr --with-ssl=/usr
            make -j"$(nproc)"
            make install
            ;;
        gnusslcore)
            ./Configure --prefix=/usr
            make -j"$(nproc)"
            make install
            ;;
        duktape)
            cd /var/tmp/build/"$DIR"
            make -f Makefile.sharedlibrary -j"$(nproc)"
            make -f Makefile.static -j"$(nproc)"
            mkdir -p /usr/include/duktape /usr/lib /usr/lib64
            cp src/duktape.h /usr/include/duktape/
            cp src/duk_config.h /usr/include/duktape/
            cp src/duktape.c /usr/include/duktape/
            cp src/duk_source_meta.json /usr/include/duktape/
            cp libduktape.so* /usr/lib/
            cp libduktape.so* /usr/lib64/
            cp libduktape.a /usr/lib/
            cp libduktape.a /usr/lib64/
            cp /usr/lib/pkgconfig/duktape.pc /usr/lib64/pkgconfig/
            cd /usr/lib
            ln -sf libduktape.so.* libduktape.so 2>/dev/null || true
            cd /usr/lib64
            ln -sf libduktape.so.* libduktape.so 2>/dev/null || true
            ldconfig
            mkdir -p /tmp
            curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup-init.sh
            sh /tmp/rustup-init.sh -y --no-modify-path --default-toolchain stable
            ;;
        asyncns86)
            [ -d /usr/lib/x86_64-linux-gnu ] && cp libasyncns.so.0.3.1 libasyncns.so.0 /usr/lib/x86_64-linux-gnu/
            ;;
        asyncnsARM64)
            [ -d /usr/lib/aarch64-linux-gnu ] && cp libasyncns.so.0.3.1 libasyncns.so.0 /usr/lib/aarch64-linux-gnu/
            ;;
        docbook)
            mkdir -p /usr/local/share/xml/docbook-xsl
            cp -r /var/tmp/build/"$DIR" /usr/local/share/xml/docbook-xsl/"$DIR"
            cd /usr/local/share/xml/docbook-xsl/"$DIR"
            chmod +x install.sh
            printf "Y\n" | ./install.sh --batch
            xmlcatalog --noout --add "public" "-//OASIS//DTD DocBook V5.0//EN" /usr/share/xml/docbook/5.0/catalog.xml 2>/dev/null
            ;;
        *)
            echo "Unknown build system: $BUILDSYS"
            exit 1
            ;;
    esac
    '

    echo "${MAGENTA}[+] Finished $NAME-$VERSION${RESET}"
done

echo "${RED}[+] Cleaning up${RESET}"
sudo umount -l "$CHARD_ROOT/dev/shm" 2>/dev/null || true
sudo umount -l "$CHARD_ROOT/dev" 2>/dev/null || true
sudo umount -l "$CHARD_ROOT/sys" 2>/dev/null || true
sudo umount -l "$CHARD_ROOT/proc" 2>/dev/null || true
sudo umount -l "$CHARD_ROOT/etc/ssl" 2>/dev/null || true

sudo rm -rf "$BUILD_DIR"

echo "${GREEN}[+] All packages built successfully!${RESET}"
