#!/bin/bash
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
CYAN=$'\033[36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

echo
echo "${GREEN}${BOLD}Chard_Mesa will bypass exec capture limitation on ChromeOS! ${RESET}${MAGENTA}${BOLD}"
echo
sleep 1

detect_gpu_freq() {
    GPU_FREQ_PATH=""
    GPU_MAX_FREQ=""
    GPU_TYPE="unknown"
    local VENDOR_FILE=""
    for card in /sys/class/drm/card[0-9]/device/vendor; do
        [ -f "$card" ] && VENDOR_FILE="$card" && break
    done

    if [ -f "$VENDOR_FILE" ]; then
        local VENDOR_ID
        VENDOR_ID=$(sudo cat "$VENDOR_FILE" 2>/dev/null | tr '[:upper:]' '[:lower:]')
        case "$VENDOR_ID" in
            0x10de) GPU_TYPE="nvidia" ;;
            0x1002) GPU_TYPE="amd"    ;;
            0x8086) GPU_TYPE="intel"  ;;
        esac
    fi

    # Intel
    if [ "$GPU_TYPE" = "intel" ] || [ "$GPU_TYPE" = "unknown" ]; then
        for f in /sys/class/drm/card*/gt_max_freq_mhz; do
            [ -f "$f" ] || continue

            GPU_FREQ_PATH="$f"
            GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
            GPU_TYPE="intel"

            echo "${BLUE}[*] Detected Intel GPU: max freq ${BOLD}${GPU_MAX_FREQ}${RESET}${BLUE} MHz${RESET}"
            return
        done
    fi

     # NVIDIA / Nouveau
    if [ "$GPU_TYPE" = "nvidia" ]; then
        if command -v nvidia-smi >/dev/null 2>&1 &&
           nvidia-smi -L >/dev/null 2>&1; then

            GPU_MAX_FREQ=$(
                nvidia-smi --query-gpu=clocks.max.graphics \
                    --format=csv,noheader,nounits |
                head -n1
            )
            GPU_FREQ_PATH="nvidia-smi"

        elif [ -f "/sys/class/drm/card0/gt_max_freq_mhz" ]; then
            GPU_FREQ_PATH="/sys/class/drm/card0/gt_max_freq_mhz"
            GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
        else
            GPU_MAX_FREQ="unknown"
        fi

        echo "${GREEN}[*] Detected NVIDIA GPU: max freq ${BOLD}${GPU_MAX_FREQ}${RESET}${GREEN} MHz"
        return
    fi

    # AMD 1
    for f in /sys/class/drm/card*/device/pp_od_clk_voltage; do
        [ -f "$f" ] || continue
        GPU_TYPE="amd"
        mapfile -t SCLK_LINES < <(sudo grep -i '^sclk' "$f" 2>/dev/null)
        if [[ ${#SCLK_LINES[@]} -gt 0 ]]; then
            MAX_MHZ=$(
                printf '%s\n' "${SCLK_LINES[@]}" |
                sed -n 's/.*\([0-9]\+\)[Mm][Hh][Zz].*/\1/p' |
                sort -nr |
                head -n1
            )

            GPU_MAX_FREQ="${MAX_MHZ:-0}"
            GPU_FREQ_PATH="$f"

            echo "${RED}[*] Detected AMD GPU: max freq ${BOLD}${GPU_MAX_FREQ}${RESET}${RED} MHz"
            return
        fi
    done

    # AMD 2
    if [ -f "/sys/class/drm/card0/device/pp_dpm_sclk" ]; then
        GPU_TYPE="amd"
        PP_DPM_SCLK="/sys/class/drm/card0/device/pp_dpm_sclk"
        GPU_MAX_FREQ=$(sudo grep -oi '[0-9]\+mhz' "$PP_DPM_SCLK" 2>/dev/null | grep -oi '[0-9]\+' | sort -nr | head -n1)
        GPU_FREQ_PATH="$PP_DPM_SCLK"
        GPU_MAX_FREQ="${GPU_MAX_FREQ:-0}"
        echo "${RED}[*] Detected AMD GPU (pp_dpm): max freq ${BOLD}${GPU_MAX_FREQ}${RESET}${RED} MHz"
        return
    fi

    # Mediatek / Vivante / Asahi / Panfrost
    SOC_LABEL=""
    if [[ -d /sys/class/drm ]]; then
        if grep -qi "mediatek" /sys/class/drm/*/device/uevent 2>/dev/null; then
            SOC_LABEL="mediatek"
            echo "${YELLOW}[*] Detected MediaTek GPU${RESET}"
        elif grep -qi "vivante" /sys/class/drm/*/device/uevent 2>/dev/null; then
            SOC_LABEL="vivante"
            echo "${MAGENTA}[*] Detected Vivante GPU${RESET}"
        elif grep -qi "asahi" /sys/class/drm/*/device/uevent 2>/dev/null; then
            SOC_LABEL="asahi"
            echo "${CYAN}[*] Detected Apple GPU${RESET}"
        elif grep -qi "panfrost" /sys/class/drm/*/device/uevent 2>/dev/null; then
            SOC_LABEL="mali"
            echo "${GREEN}[*] Detected Mali/Panfrost GPU${RESET}"
        fi
    fi

    # Mali
    for d in /sys/class/devfreq/*; do
        if grep -qi 'mali' <<< "$d" || grep -qi 'gpu' <<< "$d"; then
            if [ -f "$d/max_freq" ]; then
                GPU_FREQ_PATH="$d/max_freq"
                GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
                GPU_TYPE="${SOC_LABEL:-mali}"
                echo "${GREEN}[*] Detected Mali GPU via devfreq: max freq ${BOLD}${GPU_MAX_FREQ} ${RESET}${GREEN}Hz"
                return
            elif [ -f "$d/available_frequencies" ]; then
                GPU_FREQ_PATH="$d/available_frequencies"
                GPU_MAX_FREQ=$(sudo tr ' ' '\n' < "$GPU_FREQ_PATH" 2>/dev/null | sort -nr | head -n1)
                GPU_TYPE="${SOC_LABEL:-mali}"
                echo "${GREEN}[*] Detected Mali GPU via devfreq: max freq ${BOLD}${GPU_MAX_FREQ}${RESET}${GREEN} Hz"
                return
            fi
        fi
    done

    if [ -n "$SOC_LABEL" ]; then
        GPU_TYPE="$SOC_LABEL"
        GPU_MAX_FREQ="unknown"
        return
    fi

    # Adreno
    if [ -d "/sys/class/kgsl/kgsl-3d0" ]; then
        if [ -f "/sys/class/kgsl/kgsl-3d0/max_gpuclk" ]; then
            GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/max_gpuclk"
            GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
            GPU_TYPE="adreno"
            echo "${CYAN}[*] Detected Adreno GPU: max freq ${BOLD}${GPU_MAX_FREQ}${RESET}${CYAN} Hz"
            return
        elif [ -f "/sys/class/kgsl/kgsl-3d0/gpuclk" ]; then
            GPU_FREQ_PATH="/sys/class/kgsl/kgsl-3d0/gpuclk"
            GPU_MAX_FREQ=$(sudo cat "$GPU_FREQ_PATH" 2>/dev/null)
            GPU_TYPE="adreno"
            echo "${BLUE}[*] Detected Adreno GPU: max freq ${BOLD}${GPU_MAX_FREQ}${RESET}${BLUE} Hz"
            return
        fi
    fi

    GPU_TYPE="unknown"
    echo "${RED}[!] GPU type ${BOLD}unknown${RESET}"
}

detect_gpu_freq
GPU_VENDOR="$GPU_TYPE"
source ~/.smrt_env.sh 2>/dev/null
sudo pacman -S --noconfirm wget
sudo pacman -S --noconfirm llvm
sudo pacman -S --noconfirm python-pyyaml
sudo pacman -S --noconfirm spirv-llvm-translator
sudo pacman -S --noconfirm valgrind
sudo pacman -S --noconfirm python-mako
sudo pacman -S --noconfirm libunwind
cd
rm -rf mesa-* 2>/dev/null
LATEST=$(curl -s https://archive.mesa3d.org/ \
  | grep -oE 'mesa-[0-9]+\.[0-9]+\.[0-9]+\.tar\.xz' \
  | grep -v 'rc' \
  | sort -V \
  | tail -n1)
wget "https://archive.mesa3d.org/$LATEST"
tar xf "$LATEST"
cd "${LATEST%.tar.xz}"

if [ "$GPU_VENDOR" = "intel" ]; then
    cp src/intel/vulkan/i915/anv_device.c /tmp/anv_device.c.orig
    cp /tmp/anv_device.c.orig /tmp/anv_device.c.new
    sed -i '/I915_PARAM_HAS_EXEC_CAPTURE,/,/^   }$/{/I915_PARAM_HAS_EXEC_TIMELINE/!d}' /tmp/anv_device.c.new
    sed -i '/I915_PARAM_HAS_EXEC_TIMELINE_FENCES,/,/^   }$/d' /tmp/anv_device.c.new
    cp /tmp/anv_device.c.new src/intel/vulkan/i915/anv_device.c
    meson setup build \
        -Dprefix=/usr \
        -Dvulkan-drivers=intel,intel_hasvk \
        -Dgallium-drivers=iris,zink \
        -Dplatforms=x11,wayland \
        -Dbuildtype=release \
        -Dglx=dri \
        -Degl=enabled \
        -Dgles1=enabled \
        -Dgles2=enabled \
        -Dspirv-tools=enabled \
        -Dgallium-rusticl=false \
        -Dvideo-codecs=all \
        -Dgallium-d3d12-video=enabled \
        -Dgallium-d3d12-graphics=enabled \
        -Dintel-rt=enabled

elif [ "$GPU_VENDOR" = "amd" ]; then
    meson setup build \
        -Dprefix=/usr \
        -Dvulkan-drivers=amd \
        -Dgallium-drivers=radeonsi,zink \
        -Dplatforms=x11,wayland \
        -Dbuildtype=release \
        -Dglx=dri \
        -Dvideo-codecs=all \
        -Degl=enabled \
        -Dspirv-tools=enabled \
        -Dgles1=enabled \
        -Dgles2=enabled \
        -Dgallium-d3d12-video=enabled \
        -Dgallium-d3d12-graphics=enabled \
        -Dllvm=enabled

elif [ "$GPU_VENDOR" = "nvidia" ]; then
    meson setup build \
        -Dprefix=/usr \
        -Dvulkan-drivers=nouveau \
        -Dgallium-drivers=nouveau,zink \
        -Dplatforms=x11,wayland \
        -Dbuildtype=release \
        -Dglx=dri \
        -Dvideo-codecs=all \
        -Degl=enabled \
        -Dgles1=enabled \
        -Dgallium-d3d12-video=enabled \
        -Dgallium-d3d12-graphics=enabled \
        -Dgles2=enabled
        
elif [ "$GPU_VENDOR" = "mali" ] || [ "$GPU_VENDOR" = "mediatek" ]; then
    meson setup build \
        -Dprefix=/usr \
        -Dvulkan-drivers= \
        -Dgallium-drivers=panfrost,panthor \
        -Dplatforms=x11,wayland \
        -Dbuildtype=release \
        -Dglx=dri \
        -Degl=enabled \
        -Dgles1=enabled \
        -Dgles2=enabled

elif [ "$GPU_VENDOR" = "adreno" ]; then
    meson setup build \
        -Dprefix=/usr \
        -Dvulkan-drivers=freedreno \
        -Dgallium-drivers=freedreno \
        -Dplatforms=x11,wayland \
        -Dbuildtype=release \
        -Dglx=dri \
        -Degl=enabled \
        -Dgles1=enabled \
        -Dgles2=enabled

elif [ "$GPU_VENDOR" = "asahi" ]; then
    meson setup build \
        -Dprefix=/usr \
        -Dvulkan-drivers=asahi \
        -Dgallium-drivers=asahi \
        -Dplatforms=x11,wayland \
        -Dbuildtype=release \
        -Dglx=dri \
        -Degl=enabled \
        -Dgles1=enabled \
        -Dgles2=enabled

else
    meson setup build \
        -Dprefix=/usr \
        -Dvulkan-drivers=swrast \
        -Dgallium-drivers=swrast \
        -Dplatforms=x11,wayland \
        -Dbuildtype=release \
        -Dglx=dri \
        -Degl=enabled \
        -Dgles1=enabled \
        -Dgles2=enabled
fi

ninja -C build
sudo ninja -C build install

if [ "$GPU_VENDOR" = "intel" ] || [ "$GPU_VENDOR" = "amd" ]; then
    echo
    echo "${CYAN}${BOLD}[*] Building 32-bit Mesa for Steam (multilib)...${RESET}"
    echo
    
    sudo pacman -S --noconfirm gcc-multilib
    sudo pacman -S --noconfirm lib32-llvm
    sudo pacman -S --noconfirm lib32-libdrm
    sudo pacman -S --noconfirm lib32-libx11
    sudo pacman -S --noconfirm lib32-libxext
    sudo pacman -S --noconfirm lib32-libxfixes
    sudo pacman -S --noconfirm lib32-libxshmfence
    sudo pacman -S --noconfirm lib32-libxxf86vm
    sudo pacman -S --noconfirm lib32-libxrandr
    sudo pacman -S --noconfirm lib32-expat
    sudo pacman -S --noconfirm lib32-zlib
    sudo pacman -S --noconfirm lib32-zstd
    sudo pacman -S --noconfirm lib32-wayland
    sudo pacman -S --noconfirm lib32-clang
    sudo pacman -S --noconfirm lib32-libunwind
    sudo cp build/src/compiler/clc/mesa_clc /bin/ 2>/dev/null
    sudo cp build/src/compiler/spirv/vtn_bindgen2 /bin 2>/dev/null
    sudo chmod +x /bin/mesa_cld 2>/dev/null
    sudo chmod +x /bin/vtn_bindgen2 2>/dev/null
    
#meson setup build-host \
#  -Dprefix=$HOME/.local \
#  -Dlibdir=lib \
#  -Dmesa-clc=enabled \
#  -Dgallium-rusticl=false \
#  -Dtools=intel,nir,all

#ninja -C build-host

    cat > /tmp/i686-cross.ini << 'EOF'
[binaries]
c            = '/usr/bin/gcc'
cpp          = '/usr/bin/g++'
ar           = '/usr/bin/ar'
strip        = '/usr/bin/strip'
pkg-config   = '/usr/bin/pkgconf'
llvm-config  = '/usr/bin/llvm-config32'
cmake        = '/usr/bin/cmake'
llvm-spirv = '/usr/bin/llvm-spirv'

[built-in options]
c_args        = ['-m32']
cpp_args      = ['-m32']
c_link_args   = ['-m32']
cpp_link_args = ['-m32']

[properties]
pkg_config_libdir = '/usr/lib32/pkgconfig:/usr/share/pkgconfig:/usr/lib/pkgconfig'
llvm_spirv_libdir = '/usr/lib'

[host_machine]
system     = 'linux'
cpu_family = 'x86'
cpu        = 'i686'
endian     = 'little'

#[paths]
#mesa_clc = '~/mesa-26.0.3/build/src/compiler/clc/mesa_clc'

EOF

    if [ "$GPU_VENDOR" = "intel" ]; then
        cp src/intel/vulkan/i915/anv_device.c /tmp/anv_device.c.orig
        cp /tmp/anv_device.c.orig /tmp/anv_device.c.new
        sed -i '/I915_PARAM_HAS_EXEC_CAPTURE,/,/^   }$/{/I915_PARAM_HAS_EXEC_TIMELINE/!d}' /tmp/anv_device.c.new
        sed -i '/I915_PARAM_HAS_EXEC_TIMELINE_FENCES,/,/^   }$/d' /tmp/anv_device.c.new
        cp /tmp/anv_device.c.new src/intel/vulkan/i915/anv_device.c
        meson setup build32 \
            --cross-file /tmp/i686-cross.ini \
            -Dprefix=/usr \
            -Dlibdir=lib32 \
            -Dvulkan-drivers=intel,intel_hasvk \
            -Dgallium-drivers=iris,zink \
            -Dplatforms=x11,wayland \
            -Dbuildtype=release \
            -Dglx=dri \
            -Degl=enabled \
            -Dgles1=enabled \
            -Dgles2=enabled \
            -Dspirv-tools=enabled \
            -Dmesa-clc=system \
            -Dgallium-rusticl=false \
            -Dvideo-codecs=all \
            -Dgallium-d3d12-video=enabled \
            -Dgallium-d3d12-graphics=enabled
            
    elif [ "$GPU_VENDOR" = "amd" ]; then
        meson setup build32 \
            --cross-file /tmp/i686-cross.ini \
            -Dprefix=/usr \
            -Dlibdir=lib32 \
            -Dvulkan-drivers=amd \
            -Dgallium-drivers=radeonsi,zink \
            -Dplatforms=x11,wayland \
            -Dbuildtype=release \
            -Dglx=dri \
            -Dvideo-codecs=all \
            -Degl=enabled \
            -Dgles1=enabled \
            -Dgles2=enabled \
            -Dspirv-tools=enabled \
            -Dmesa-clc=system \
            -Dgallium-d3d12-video=enabled \
            -Dgallium-d3d12-graphics=enabled \
            -Dgallium-rusticl=false
    fi

    ninja -C build32
    sudo ninja -C build32 install
else
    echo "Skipping 32-bit Mesa (not applicable for ${GPU_VENDOR})"
fi

cd
rm -rf ~/mesa-* 2>/dev/null
