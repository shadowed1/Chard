RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo
echo "${RESET}${GREEN}"
echo "Chard Changelog:"
echo "${RESET}${CYAN}"
echo "0.01: Initial Release"
echo
echo "0.02: Added Wayland or X script. Prepend wx to an app if it cannot find display :0. Added header install command for Linux Kernel. Cleaned up Sommelier tmp directory. Added chard_mount and chard_unmount commands. Enabled KVM kernel flag. Added GParted, UNetBootin and QEMU support. QEMU will use KVM + OpenGL for excellent performance!Now we can format USB's with nearly all file systems and create bootable media i0n ChromeOS."
echo
echo "0.03: Added Arch Linux support for 10-30x faster install time. Added Steam support (139 only), added native volume controls for Arch."
echo
echo "0.04: Updated to include Steam and Flatpak support for ChromeOS 141+. Chard Arch gets SMRT support"
echo
echo "0.05: Isolated Chard forked bubblewrap so other apps will use regular bubblewrap. Added chard unmount command. xfce4 now starts with CHard Arch. Fixed minor bugs."
echo
echo "0.06: Fixed GPU error popup in Mediatek GPU's. (still working on acceleration), Added Firefox support, added SMRT support for yay, fixed Minecraft audio support."
echo
echo "0.07: Fixed audio for ARM64. Fixed wayland crash when launching Brave. Moved prismlauncher to its own wrapper. Added wrapper updates to reinstaller. Fixed version command."
echo
echo "0.08: Added Pipewire config creation script. Implemented pipewire with native ChromeOS socket support. Cleaned up unmount procedure. Fixed occasional internet loss issue when asleep. Fixed Steam to run as User for ChromeOS 140+. Added extra dark theme support. Added volume controls for pulseaudio using chardwire."
echo
echo "0.09: Fixed Wayland crash issue due to Brave alias."
echo
echo "0.10: Fixed Steam local files window from not expanding. Fixed Steam games having flickering lines bug when paired with multiple display + Freesync."
echo
echo "0.11: Significantly improved Pipewire support."
echo
echo "0.12: Downgrade Mesa for Intel iGPU's to fix Vulkan."
echo
echo "0.13: Created custom virtual pulseaudio implementation for simultaneous audio stream support. Added Pulseaudio support."
echo
echo "0.14: Greatly increased amount of commands able to run outside of chroot. Created chard_preload generation script. Added specific ways to run chariot checkpoints. Created Chardonnay script to run sommelier and Xwayland natively in ChromeOS. Added HDMI, 3.5mm, Bluetooth and mute toggle support for Chard Audio controls (chardwire). Added Steam GPU detection script."
echo
echo "0.15: Rolled back LD_PRELOAD changes and removed Chardonnay for Chard Arch. Avoids confusion and Gentoo will be far more capable here. Fixed stale audio download links."
echo "${RESET}"
