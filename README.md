<p align="center">
  <img src="https://i.imgur.com/h12e32A.png" alt="logo" width="5000" />
</p>  

<p align="center">
  <img src="https://i.imgur.com/OcNXgOX.png" alt="logo" width="5000" />
</p>  

<br>


# How to Install:

<br>

- For **ChromeOS, and most Linux Distros,** press `ctrl-alt-t`, open a crosh `shell` and copy paste:

<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_download?$(date +%s)")</pre>

<br>

 - Option 1 is Chard Arch, which supports Steam, Heroic, Flatpak, and is the recommended option for most users. <br>
- Option 2 is Chard Gentoo, tailored for ChromeOS development. This enables running Gentoo binaries + toolchain in ChromeOS outside of chroot. <br>

After choosing, it downloads the installer. Running the installer requires VT-2 logged in as chronos, or enabling sudo in the chromeOS shell. <br>

https://www.chromium.org/chromium-os/developer-library/guides/device/developer-mode/

<br>

Enabling sudo in ChromeOS shell natively using minijail LD_PRELOAD: <br>
https://github.com/shadowed1/sudoCrosh <br>

Emulating sudo in ChromeOS shell with encrypted bidirectional FIFO: <br>
https://github.com/shadowed1/Sucrose <br>

## About Chard (*Chrome-Arch Development*):

### Chard is a chroot (change root) that is Arch or Gentoo Linux.
Safely lives inside an existing ChromeOS or Linux install without prepending its paths to the system.

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

### Features:

<br>

- Chard auto-detects the Host's hardware and builds Arch or Gentoo + psuedo-Kernel automatically.
- Includes ability to resume installer if interrupted; even if system shuts down.

<br>

- Supports running a vast array of apps and games (including Wine and Proton).
- Control app volume with ChromeOS volume controls.

<br>

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

- Supports mounting external drives and Android devices. Connect prior to entering Chard. 
- Implements `virtm`, a program emulating mouse capture support; bypassing exo security delegate. 

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
- And too many to test. 

### Commands (Some not listed) <br>
- `chard <binary> <arguments>` -- to run a command wrapped within /usr/local/chard paths outside of chroot (Not fully supported right now).
- `chard root` or `cr` -- Enter Chard Chroot with Sommelier Xwayland GPU acceleration with OpenGL,Vulkan, GUI, and audio support.
- `chard safe` or `cs` -- Enter Chard Root without GUI support -- Useful for using emerge or entering Chard prior to finishing Installer.


*In ChromeOS:* 
- `autoclicker <clicks-per-second>` -- Run an autoclicker script in ChromeOS!
- `virtm` Start mouse capture/lock script. Allows spinning around, Ctrl - C to exit. 
- `chard reinstall` -- Option 1 for fast reinstall (does not remove). Option 2 is a full reinstall (removes Chard).
- `chard uninstall` -- Remove Chard. Refresh shell to remove .bashrc entries.
- `chard help` -- Show help examples.
- `chard chariot` or `chariot` -- Chard's companion tool for setting itself up with a checkpoint system.
- `chardonnay` -- Launch Sommelier in ChromeOS natively (Gentoo only -- WIP).
- `chard version` -- Check for updates.
- `chard unmount` or `cu` -- Force chard to unmount as if exiting (force kill).
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
- `exit` -- Leave Chard Root
- `flatpak override --user --nosocket=wayland org.app.Appname` -- Example for Flatpak troubleshooting

<br>

### How to use:

- After installer finishes, open a new ChromeOS shell via crosh shell to continue.
- Type in `cr` or `chard_root` to enter Chard Chroot with Sommelier support.
- When running sudo, use `sudo -E` instead.
- `flatpak override --user --nosocket=wayland app.Appname` Might be needed for flatpak.
- When running GParted, make sure to unmount the device in ChromeOS first; otherwise you will need to re-run GParted command.
- `startxfce4` launches a taskbar + app drawer. Right click -> panel -> panel preferences -> uncheck lock and click dots on the sides to drag around.
- Create a launcher in items which then allows for custom app shortcuts.

QEMU Example: 

<br>

```
xhost +SI:localuser:root
sudo qemu-system-x86_64 \
  -m 4G \
  -cpu host \
  -smp 4 \
  -machine type=q35,accel=kvm \
  -drive file=/home/chronos/ubuntu.qcow2,format=qcow2 \
  -cdrom ~/Downloads/ubuntu.iso \
  -display sdl,gl=on \
  -boot d \
  -name "Ubuntu VM"
```

  - -m 4G allocated 4GB of RAM to the VM
  - -smp 4 allocates 4 threads to the VM
  - accel=kvm enables GPU passthrough
  - -display sdl,gl=on enables OpenGL acceleration

<br>

- Use `pavucontrol` for volume mixer for Steam games.


<br>

- `startxfce4` to launch a basic app launcher shelf that can be adjusted.
- Do not exit a Chard shell if you have other ones open. Append & at end of an app to run more apps in same shell. 

<br>

### *Known Issues - Some of these issues might not be easily fixed:*

- Chard Arch cannot run multiple `chard root` shells simultaneously (use xfce4's terminal app)
- *Mediatek GPU support is currently being worked on (hard!) - ARM64 is software rendering only for now.

<br>

- Chrome app shelf is missing icon + pin support. Remedied by customizing xfce4 shelf or install KDE Plasma. 
- Entering Chard Root with Sommelier support will generate some harmless errors.

<br>

- Exiting Chard closes all running apps inside Chard, so please save your work before exiting!

- Microphone support needs to be re-done. 
- When using OBS game capture, it is recommended (and required if using chard arch) to run everything in one shell. So run `obs & prismlauncher` for example. OBS is a difficult app to fully implement.

<br>

- LXC and VM support is not fully implemented.
- Apps using Pulse Audio uses a different volume curve than apps using ALSA.

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
- 0.24: `Updated virtm to support USB mice, and prioritize them over touchpad. This enables touchpad to function normally, while a USB mouse becomes a virtual touchscreen to enable spinning around in 3D environments. Fixed dbus address error. Fixed Steam black screen on first time log in with GPU acceleration enabled for web views.` <br<br>
- 0.25: `Added support for ChromeOS 104. Added chard_sort command for Arch to sort packages by size.` <br><br>
<br>

### Acknowledgements
- *Google* - Ending official Steam support gave me motivation to learn to run Linux apps inside ChromeOS.
- *Terry Stormchaser* - Spending time testing Borealis alternatives, testing Chard + reporting bugs, and providing ideas.
- *DennyL* - Testing Chard, reporting bugs, and making suggestions.
- *Saragon* - Providing documentation and suggestions.
- *Zhil* - Sending documentation for XFCE4 theme ideas.
- *Sebanc* - Helping me move from Gentoo to Arch and enabling audio for Arch.
- *days* - Helping fix audio issues with Wine, chard_garcon, and more. 
- *WeirdTreeThing* - Help with further supporting pipewire support. Great ideas for ARM64 GPU acceleration. 
