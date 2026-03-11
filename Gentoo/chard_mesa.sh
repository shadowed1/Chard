#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

MESA_DIR="/usr/portage/media-libs/mesa"
PATCH_DIR="/etc/portage/patches/media-libs/mesa"
PATCH_FILE="$PATCH_DIR/anv-skip-exec-capture-check.patch"
WORK_BASE="/var/tmp/portage"
echo
echo "${GREEN}${BOLD}Chard_Mesa will bypass exec capture limitation on ChromeOS! ${RESET}"
echo
sleep 1
MESA_VERSIONS=$(ls "$MESA_DIR"/*.ebuild | grep -v '9999' | sed 's/.*mesa-//;s/\.ebuild//')
echo "${YELLOW}Found Mesa versions: "
echo "${BOLD}$MESA_VERSIONS ${RESET}"
echo
sleep 1
UNPACKED=$(ls -d "$WORK_BASE"/media-libs/mesa-*/work/mesa-*/src/intel/vulkan/i915/anv_device.c 2>/dev/null | head -1)

if [ -z "$UNPACKED" ]; then
    LATEST=$(portageq best_version / media-libs/mesa | sed 's/media-libs\/mesa-//')
    if [ -z "$LATEST" ]; then
        echo "${RED}Could not determine installed Mesa version${RESET}"
        exit 1
    fi
    echo "${YELLOW}Selected Mesa version:"
    echo "${BOLD}$LATEST ${RESET}"
    echo
    ebuild "$MESA_DIR/mesa-$LATEST.ebuild" clean unpack
    UNPACKED=$(ls -d "$WORK_BASE"/media-libs/mesa-*/work/mesa-*/src/intel/vulkan/i915/anv_device.c 2>/dev/null | head -1)
fi

if [ -z "$UNPACKED" ]; then
    echo
    echo "${RED}Could not find anv_device.c ${RESET}"
    echo
    sleep 5
    exit 1
fi

echo
echo "${GREEN}Using source: "
echo "${BOLD}$UNPACKED ${RESET}"
echo

cp "$UNPACKED" /tmp/anv_device.c.orig
cp /tmp/anv_device.c.orig /tmp/anv_device.c.new
sed -i '/I915_PARAM_HAS_EXEC_CAPTURE,/,/^   }$/{/I915_PARAM_HAS_EXEC_TIMELINE/!d}' /tmp/anv_device.c.new
sed -i '/I915_PARAM_HAS_EXEC_TIMELINE_FENCES,/,/^   }$/d' /tmp/anv_device.c.new

if diff /tmp/anv_device.c.orig /tmp/anv_device.c.new > /dev/null; then
    echo "[!] No differences found - file may have already been patched or structure changed"
    exit 1
fi

mkdir -p "$PATCH_DIR"
diff -u /tmp/anv_device.c.orig /tmp/anv_device.c.new | \
    sed 's|/tmp/anv_device.c.orig|a/src/intel/vulkan/i915/anv_device.c|' | \
    sed 's|/tmp/anv_device.c.new|b/src/intel/vulkan/i915/anv_device.c|' \
    > "$PATCH_FILE"

echo "${GREEN}Patch written: "
echo "${BOLD}$PATCH_FILE ${RESET}"
echo ""
EMERGE_VERSION=$(ls "$MESA_DIR"/*.ebuild | grep -v '9999' | sort -V | tail -1 | sed 's/.*mesa-//;s/\.ebuild//')
echo "${GREEN}Emerging Mesa: ${BOLD}$EMERGE_VERSION${RESET}"
echo
sudo -E emerge -1 =media-libs/mesa-$EMERGE_VERSION
