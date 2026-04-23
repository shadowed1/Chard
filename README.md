<p align="center">
  <img src="https://i.imgur.com/h12e32A.png" alt="logo" width="5000" />
</p>  

<p align="center">
  <img src="https://i.imgur.com/OcNXgOX.png" alt="logo" width="5000" />
</p>  

<br>


# How to Install:

<br>

1.)   For **ChromeOS, and most Linux Distros,** press `ctrl-alt-t`, open a crosh `shell` and copy paste:

<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_download?$(date +%s)")</pre>

<br>

2.)   Choose your distro: <br>
   `Option 1` is Arch   - Supports Steam, Heroic, Flatpak, and is the recommended option for most users. <br>
   `Option 2` is Gentoo - Tailored for ChromeOS development. Run binaries + toolchain in ChromeOS. <br>
  
3.)   For ChromeOS, please use VT-2 to proceed. `CTRL-ALT-REFRESH` enters VT-2. `CTRL-ALT-BACK` exits VT-2.
- To login, type `chronos` and run these three commands on their own:
```
cd
sudo mv Chard_Installer /usr/local
sudo bash /usr/local/Chard_Installer
```
<br>

4. Follow the instruction on screen. `CTRL-ALT-BACK` returns back to ChromeOS. Sleep is recommended to be disabled while installing. <br>

5. Once install is finished in VT-2, press `CTRL-D` to log out and log back in as `chronos`. Type `cr` or `chard root` to start. <br>

6. Return back to ChromeOS shell, and `xfce4-terminal` should appear. Run apps through there, or through the app launcher if Crostini is installed. <br>

Running chard directly in ChromeOS shell and having it start automatically on boot is possible using this tool:
<br>

*Enabling sudo in ChromeOS shell natively using minijail LD_PRELOAD:* 
<br>
`https://github.com/shadowed1/sudoCrosh` <br>

## About Chard (*Chrome-Arch Development*):

### Chard is a chroot (change root) that is Arch or Gentoo Linux.
Safely lives inside an existing ChromeOS or Linux install without prepending its paths to the system.

- Open Source and free forever. 
- Automated rolling-release installer will build everything needed with full hardware detection.
- Run Linux Apps with GUI support natively inside ChromeOS with GPU acceleration!*
- Audio support over Bluetooth, USB, 3.5mm, and internal speakers with CRAS + pulse virtualization.
- Supports Flatpak, Steam, Heroic, Wine, and even Mouse Capture emulation for first person games.  
- *Chard is in development. Bug reports, suggestions, and ideas are greatly appreciated.*
- Can be safely uninstalled at anytime without altering our ChromeOS install! 
  
<br>

### Examples:

<br>

*Steam + Game Support:*
<p align="center">
  <img src="https://i.imgur.com/ILkV5tB.png" alt="logo" width="1000" />
</p>

<br>

*Firefox:*
<p align="center">
  <img src="https://i.imgur.com/5fgNRlJ.png" alt="logo" width="1000" />
</p>

<br>

*QEMU running VMs:*
<p align="center">
  <img src="https://i.imgur.com/FpEkYoM.png" alt="logo" width="1000" />
</p>  

<br>

*Minecraft Java + Prism Launcher:*
<p align="center">
  <img src="https://i.imgur.com/MplsaH4.jpeg" alt="logo" width="1000" />
</p>
<br>


*Brave, Codium, Thunar, VLC, xfce4:*
<p align="center">
  <img src="https://i.imgur.com/dkv1NIn.jpeg" alt="logo" width="1000" />
</p>  

<br>

*OBS:*
<p align="center">
  <img src="https://i.imgur.com/1jN6fHc.png" alt="logo" width="1000" />
</p>

<br>

*LibreOffice*
<p align="center">
  <img src="https://i.imgur.com/tuZNOsF.png" alt="logo" width="1000" />
</p>

<br>

*GIMP*
<p align="center">
  <img src="https://i.imgur.com/Ys9HuWV.png" alt="logo" width="1000" />
</p>

<br>

*Now with Icon Support!*
<p align="left">
  <img src="https://i.imgur.com/OOKwqZ5.png" alt="logo" width="200" />
</p>

<br>

### Features:

<br>

- Chard auto-detects the Host's hardware and builds Arch or Gentoo + psuedo-Kernel automatically.
- Includes ability to resume installer if interrupted; even if system shuts down.

<br>

- Supports running a vast array of apps and games (including Wine and Proton).
- Control app volume with ChromeOS volume controls.

<br>

- Supports native mouse capture/lock for games!
- Greatly exceeds Crostini performance and can achieve superior performance to Borealis (RIP) with significantly lower memory overhead.
- USB + Bluetooth controller support for games.

<br>

- Semi-intelligent CPU task scheduler for building packages.
- ChromeOS' Downloads folder is shared when entering Chard Root, allowing for fast file sharing. 

<br>

- Includes most compiling tools as a basic toolchain. 
- Uses Sommelier to communicate with ChromeOS' window management and support Desktop Environments, Apps, Games, and more.

<br>

- Runs GUI apps with full GPU acceleration including audio support for Chromebooks; including HDMI audio out. 
- Native full screen support, multi-monitor support, and supports ChromeOS window managment gestures. 

<br>

- Does *not* require removing files and includes an uninstaller script to clean up after itself.
- When Installer finishes or exits a log file, 'chariot.log', is created for debugging.

<br>

- Can run certain apps directly from Chard in the Host OS (testing ChromeOS only).
- Extremely resource light; RAM usage is below 100MB footprint.

<br>

- Supports mounting external drives and Android devices. Connect prior to entering Chard.
- Patches and Builds Sommelier with mouse capture + icon support. 

<br>

- Exports bindfs to ChromeOS shell, bypassing noexec mount on external drives, enabling Steam to use external drives for Chard!
- Implements ChromeOS' native icon system using Crostini as a Bridge. 

<br>

### Requirements:

<br>

- **Please do not install without a USB recovery as this is under rapid development, mistakes happen, and bugs will exist!**

<br>

- *Requires 16GB of storage, 2GB of RAM, and an internet connection.*
- *CPU Support: x86_64 & ARM64 - CPU must be 64-bit*
- *GPU Support: AMD, Intel, NVIDIA, ARM, Mali, Rockchip, Mediatek, Adreno, & Vivanti*

<br>

- *Requires Developer Mode if on ChromeOS.* <br>
- *Untested with Brunch Toolchain, Chromebrew, and dev_install; but Chard is independent of these tools.*

<br>

- *Chromebooks with 8GB of RAM and 8+ threads can build Chard in 20-60 minutes. Gentoo install takes longer.*
- *Lower end Chromebooks (2-4 thread Intel, Mediatek 500 series, and older) can expect much longer install times.*

<br>

# Chard will use Pacman or Emerge to build: <br>
- Make
- CMake
- Curl with OpenSSL
- GCC
- Python + Pip
- Git
- File + LDD
- CMake
- Perl
- Meson
- Ninja
- Rust
- Ruby
- OpenSSL
- LLVM
- Clang
- Mesa
- Vulkan + Vulkan Tools
- Sommelier
- Wayland
- X11
- XFCE4
- VLC
- KDE Plasma
- Brave Browser
- Flatpak
- xarchiver
- Gedit
- Codium
- GIMP
- LibreOffice
- Thunar
- GParted
- UNetBootin
- QEMU with VM support
- Prism Launcher + Minecraft Java
- OBS with Game Capture, Recording, and Streaming support
- Heroic Game Launcher
- Steam
- Firefox
- Sober
- And too many to test. 

### Commands (Some not listed) <br>


*In ChromeOS:* 
- `chard root` or `cr` -- Enter Chard Root with Sommelier Xwayland GPU acceleration with OpenGL,Vulkan, GUI, mouse capture, icons, and audio support.
- `chard safe` or `cs` -- Enter Chard Root without GUI support -- Useful debugging. 
- `chard unmount` or `cu` -- Force chard to unmount as if exiting (force kill).
- `autoclicker <clicks-per-second>` -- Run an autoclicker script in ChromeOS!
- `chard reinstall` -- Option 1 for fast reinstall (does not remove). Option 2 is a full reinstall (removes Chard).
- `chard uninstall` -- Remove Chard. Refresh shell to remove .bashrc entries.
- `chard help` -- Show help examples.
- `chard chariot` or `chariot` -- Chard's companion tool for setting itself up with a checkpoint system.
- `chardonnay` -- Launch Sommelier in ChromeOS natively (Gentoo only -- WIP).
- `chard version` -- Check for updates.
- `chard_mount` -- Tell chard to mount an external drive.
- `chard_unmount` -- Tell chard to umount an external drive. 
- `chard_mtp_mount` -- Tell chard to mount an Android device that is connected.
- `chard_mtp_unmount` -- Tell chard to unmount the Android device. 
- `rainbow` -- Enable a rainbow shell in ChromeOS. (Fun extra)

<br>

*Inside Chard Root*
- `SMRT` or `SMRT <1-100>` -- For compiling - auto allocate threads or specify in % how many threads you want to allocate.
- `chard_scale display 1.5` -- Set display scaling to 1.5X scaling.
- `chard_scale cursor 64` -- Set cursor to 64px.
- Refresh a new shell after adjusting scaling.
- Prepend `wx` to an app to try wayland and x11 if unsure.
- `chard_mount` to mount a USB device (ignores SSD and USB devices) for UNetBootin.
- `chard_unmount` or `exit` to unmount the device.
- Prepend `root` to an app that requires user namespace creation and it might work.
- `chariot 144` -- Resume on checkpoint 144 and continue until Chariot finishes.
- `chariot -s 90` -- Resume on checkpoint 90 and exit after finishing that specific checkpoint.
- `chard_debug` -- List Chard's environmental variables in alphabetical order with colors. 
- `exit` -- Leave Chard Root
- `flatpak override --user --nosocket=wayland org.app.Appname` -- Example for Flatpak troubleshooting

<br>

# How to use:

- After installer finishes, open a new ChromeOS shell via crosh shell to continue.
- Type in `cr` or `chard_root` to enter Chard Chroot with Sommelier support.
- When running sudo, use `sudo -E` to preserve environmental variables.
- `flatpak override --user --nosocket=wayland app.Appname` Might be needed for flatpak.
- When running GParted, make sure to unmount the device in ChromeOS first; otherwise you will need to re-run GParted command.
- `startxfce4` launches a taskbar + app drawer. Right click -> panel -> panel preferences -> uncheck lock and click dots on the sides to drag around.
- Create a launcher in items which then allows for custom app shortcuts.

QEMU Example: 

<br>

```
# Download .iso. I use chrome browser and download iso to my chromeos downloads folder.
# Inside chard, I run:
qemu-img create -f qcow2 ~/win10.qcow2 40G # to create a 40GB disk image called win10 inside chard's home folder. 
# Install Windows:
chard_qemu -m 4G -cpu host -smp 4 -machine type=q35,accel=kvm -drive file=~/win10.qcow2,format=qcow2 -cdrom ~/user/MyFiles/Downloads/Win10_22H2_English_x64v1.iso -display sdl,gl=on -boot d -name "Win10"
# After it finishes, close and re-launch without  cdrom:
# I disconnect from internet here to skip internet login prompt (enable function keys in chromeos settings to active shift + f10 in windows 10)
chard_qemu -m 4G -cpu host -smp 4 -machine type=q35,accel=kvm -drive file=~/win10.qcow2,if=virtio,cache=writeback,format=qcow2,discard=unmap -vga qxl -display sdl -audiodev pa,id=snd0 -device ich9-intel-hda -device hda-output,audiodev=snd0 -name "Win10"

# Above command allocated 4GB of RAM and 4 cpu cores
# Reconnect to internet after it is set up.

```
More QEMU documentation: <br>
`https://sysguides.com/install-windows-11-on-kvm#18-add-a-tpm-device-for-windows-requirements`

<br>

- Use `pavucontrol` for volume mixer if needed.


<br>

- `startxfce4` to launch a basic app launcher shelf that can be adjusted.
- Do not exit a Chard shell if you have other ones open. Append & at end of an app to run more apps in same shell. 

<br>

### *Known Issues - Some of these issues might not be easily fixed:*

- Chard Arch cannot run multiple `chard root` shells simultaneously (use xfce4's terminal app)
- *Mediatek GPU support is currently being worked on (hard!) - ARM64 is software rendering only for now.

<br>

- Entering Chard Root with Sommelier support will generate some harmless errors.
- Xbox Series X controller not working with bluetooth. 

<br>

- Exiting Chard closes all running apps inside Chard, so please save your work before exiting!
- LXC and VM support is not fully implemented.

<br>

- Steam often work best with Proton 10.05 (as of March 31st, 2026)
- Sucrose users can launch Chard with `sudo chard root`. Sucrose users should uninstall Chard with VT-2.  
<br>

### Changelog:

- 0.01: `Initial Release` <br><br>
- 0.02: `Added Wayland or X script. Prepend wx to an app if it cannot find display :0. Added header install command for Linux Kernel. Cleaned up Sommelier tmp directory.
Added chard_mount and chard_unmount commands. Enabled KVM kernel flag. Added GParted, UNetBootin and QEMU support. QEMU will use KVM + OpenGL for excellent performance!Now we can format USB's with nearly all file systems and create bootable media in ChromeOS!` <br><br>
- 0.03: `Added Arch Linux support for 10-30x faster install time. Added Steam support (139 only), added native volume controls for Arch.` <br><br>
- 0.04: `Updated to include Steam and Flatpak support for ChromeOS 141+. Chard Arch gets SMRT support` <br><br>
- 0.05: `Isolated Chard forked bubblewrap so other apps will use regular bubblewrap. Added chard unmount command. xfce4 now starts with CHard Arch. Fixed minor bugs.` <br><br>
- 0.06: `Fixed GPU error popup in Mediatek GPU's. (still working on acceleration), Added Firefox support, added SMRT support for yay, fixed Minecraft audio support.` <br><br>
- 0.07: `Fixed audio for ARM64. Fixed wayland crash when launching Brave. Moved prismlauncher to its own wrapper. Added wrapper updates to reinstaller. Fixed version command.` <br><br>
- 0.08: `Added Pipewire config creation script. Implemented pipewire with native ChromeOS socket support. Cleaned up unmount procedure. Fixed occasional internet loss issue when asleep. Fixed Steam to run as User for ChromeOS 140+. Added extra dark theme support. Added volume controls for pulseaudio using chardwire.` <br><br>
- 0.09: `Fixed Wayland crash issue due to Brave alias.` <br><br>
- 0.10: `Fixed Steam local files window from not expanding. Fixed Steam games having flickering lines bug when paired with multiple display + Freesync.` <br><br>
- 0.11: `Significantly improved Pipewire support.` <br><br>
- 0.12: `Downgrade Mesa for Intel iGPU's to fix Vulkan.` <br><br>
- 0.13: `Created custom virtual pulseaudio implementation for simultaneous audio stream support. Added Pulseaudio support.` <br><br>
- 0.14: `Greatly increased amount of commands able to run outside of chroot. Created chard_preload generation script. Added specific ways to run chariot checkpoints. Created Chardonnay script to run sommelier and Xwayland natively in ChromeOS. Added HDMI, 3.5mm, Bluetooth and mute toggle support for Chard Audio controls (chardwire). Added Steam GPU detection script.` <br><br>
- 0.15: `Rolled back LD_PRELOAD changes and removed Chardonnay for Chard Arch. Avoids confusion and Gentoo will be far more capable here. Fixed stale audio download links.` <br><br>
- 0.16: `Fixed slow unmount issues and minor issues` <br><br>
- 0.17: `Added external drive + SD card support. Fixed eselect issue on Chard Gentoo. Fixed minor typos.` <br><br>
- 0.18: `Added ChromeOS_PowerControl GUI support. Fixed minor typos.` <br><br>
- 0.19: `Added autoclicker script. Can be run outside or inside chroot. Fixed powercontrol-gui launching in foreground. Improved chard_flatpak wrapper. Fixed linux_api_headers error on Arch when upgrading. ` <br><br>
- 0.20: `Enabled Firefox audio. Significantly improved Flatpak support; including Sober support! Added uname spoofer, prerequisites for Chard Lite, removed bloatware from chariot, and added cleanup commands for Chard Arch post-install.` <br><br>
- 0.21: `Added virtm. This enables virtual touchscreen mouse; enabling chromebooks with touchscreens to use emulated mouse capture. Run virtm prior to launching app.` <br><br>
- 0.22: `Further improved Firefox support to enable GPU accleration with audio support. Added resolv.conf copy during reinstall - Thanks to DennyL for reporting. Added cleanup script for Chard Arch. Added pacman update cleaner and improved GPU detection script for chariot` <br><br>
- 0.23: `Implemented Arch Linux package retry script for chariot. Fixed flatpak wrapper that causes /var/lib error. Fixed Arch Linux user id error for ARM64. Added safety guardrails to installer when removing Chard. Fixed audio loss issue on Arch for ARM64 on ChromeOS 144.` <br><br>
- 0.24: `Updated virtm to support USB mice, and prioritize them over touchpad. This enables touchpad to function normally, while a USB mouse becomes a virtual touchscreen to enable spinning around in 3D environments. Fixed dbus address error. Fixed Steam black screen on first time log in with GPU acceleration enabled for web views.` <br><br>
- 0.25: `Added support for ChromeOS 104. Added chard_sort command for Arch to sort packages by size.` <br><br>
- 0.26: `Fixed Chard Gentoo emerge issues during installer. Added gles2 USE flags. Replaced chronos with $CHARD_USER variable when creating chroot. Added $CHARD_ROOT environmental variable detection in the installer to auto-fill existing install path rather than rely on default only. Fixed $LD_LIBRARY_PATH and $PATH duplication errors. Added additional sbin paths and dynamic /opt/*/bin path detection for Chard Arch. Added thunar to be default file manager in .bashrc. Fixed VLC for Chard Arch on new installs. Added .$USERrc file being sourced by Chard's .bashrc; allowing additional .bashrc entries without overwriting on reinstall.` <br><br>
- 0.27: `Altered some group ID's to match ChromeOS'. Improved non-ChromeOS support. Added sanitization safeguard to .bashrc on uninstall. Added required sys-apps/shadow dependency for coreutils on Gentoo. Fixed typo for installing Vulkan on Chard Arch on Virtual Machines. Fixed .bashrc thunar bug causing shell to hang. Fixed Steam not opening Thunar when opening files. Added xfce4 dark theme to be autoapplied during installer. Added Language checker to no longer auto-apply English and instead use ChromeOS'. Patched Mesa for Intel iGPU's to re-enable Vulkan on ChromeOS with chard_mesa.` <br><br>
- 0.28: `Added bindfs to chard_mount, bypassing noexec limitation for external drives. This enables Steam to use external drives. Added Shortcut and Icon support for Chard using a VM as an app launcher.` <br><br>
- 0.29: `Patched Color Inversion bug on ChromeOS 145 ARM64 for Chard Arch and Chard Gentoo. Fixed Bindfs from being properly called on chard_mount. Enabled microphone support. Equalized pulseaudio and ALSA volume.` <br><br>
- 0.30: `Native mouse capture achieved. Thanks to Days for finding how to actually enable that. To use mouse capture, launch chard using "cg" or "chard game". App Icons will not be enabled in this mode, but that will be worked on soon.` <br><br>
- 0.31: `Mouse capture support with app icons enabled. Removed "cg" or "chard game" since it is no longer needed. Integrated sommelier patch logic for "chard_sommelier_patch" to enable mouse capture on all devices.` <br><br>
- 0.32: `Patched default.pa to bypass unload-module module-udev-detect limitation. Added back "cg" or "chard game" due to mouse capture breaking right click and menu interactions on certain apps.` <br><br>
- 0.33: `Added chard_startup command. Chard can now start on boot! Implemented smarter detection for running scripts in incorrect locations.` <br><br>
- 0.34: `Added right click + context menu support for org.chromium.arc. Forked sommelier to own repo due to the amount of edits made. Re-removed "chard game" or "cg" due to fixing right click issue. Added additional cleanup procedures with new chard startup service. Added chard_qemu wrapper. Updated chard version command to show changelog. Increased startup .conf wait timer.` <br><br>
- 0.35: `Added stop, startup command for chard_bridge_daemon. Added chard_shortcut_daemon to auto-sync icons and shortcuts. Added 3rd option in Reinstall for chard_startup command. Cleaned up exiting Reinstaller. Added ability for chard_bridge_daemon to automatically install and run in Crostini.` <br><br>
- 0.36: `Fixed bugs with chard_mesa and now relying on Steam's GPU drivers (again). Added vulkan_tester script. Improved Flatpak to now support running far more apps. Improved OBS support to now record + stream Vulkan. Added pacman easter egg. Updated Dowmloader instructions. Removing brave, prismlauncher, and rust from chariot to reduce Arch down to 11GB!. ` <br><br>
- 0.37: `Added ChromeOS 103 support. Thanks to gd_minecraft_programmer for creating that syntax. Fixed chard_bridge_daemon not working on some devices. Added chard_timezone_daemon to keep Chard's timezone synced with ChromeOS'. Added /opt to paths. Added "chard log" command to run in Host shell to compress a log to our Downloads folder.` <br><br>
- 0.38: `Downgrading Flatpak to fix it. The recent patch made it incompatible with Chard. Added Sober wrapper to automatically fix text issue. Added dbus-launch initialization on startup to fix Thunar not opening properly. Attempting to fix language not being properly set on fresh install.` <br><br>
<br><br>


### Acknowledgements - This project would not exist without the help and support from the ChromeOS community. 

- *Google* - Ending official Steam support gave me motivation to learn to run Linux apps inside ChromeOS.
- *Terry Stormchaser* - Spending time testing Borealis alternatives, testing Chard + reporting bugs, and providing ideas.
- *DennyL* - Testing Chard, reporting bugs, and making suggestions.
- *Saragon* - Providing documentation and suggestions.
- *Zhil* - Sending documentation for XFCE4 theme ideas.
- *Sebanc* - Helping me move from Gentoo to Arch and enabling audio for Arch.
- *days* - Helping fix audio issues with Wine, chard_garcon, enabled mouse capture/lock, and more. 
- *WeirdTreeThing* - Help with further supporting pipewire support with their vast audio knowledge. Great ideas for ARM64 GPU acceleration.
- *C0d1ngR4bb1t* - Created and tested syntax for external USB support.
- *gd_minecraft_programmer* - Created and tested syntax to support ChromeOS 103 and older.
- *nobody067481* - Found bugs with installer and tested a lot of emulators.
- *DarkDonkey* - Testing QEMU and working on improving performance.
- *Quince* - Recommending GUI apps that work with Chard.
