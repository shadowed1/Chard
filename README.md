<p align="center">
  <img src="https://i.imgur.com/h12e32A.png" alt="logo" width="5000" />
</p>  

<br>


### How to Install:

<br>

- For **ChromeOS, FydeOS, and most Linux Distros,** open crosh, type in `shell` and paste:

<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/bin/chard_download?$(date +%s)")</pre>

<br>

### About Chard (*Chrome-Arch Development*):

<br>

- Run Linux Apps with GUI support natively inside ChromeOS with GPU acceleration!
- This is either an Arch or Gentoo Stage3 chroot that builds an independent Linux environment in a semi-sandboxed environment.
- Automated install will build everything needed with full hardware detection.
- *Chard is in early development. Bug reports, suggestions, and ideas are greatly appreciated.*
  
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
- Greatly exceeds Crostini performance and can achieve superior performance to Borealis (RIP) with significantly lower memory overhead.

<br>

- Intelligent CPU task scheduler for building packages.
- User can customize how many threads Chard can use dynamically. Useful for devices with low memory.
- Hardware detection scripts allows compilers to enable native architectural tweaks.
- ChromeOS' Downloads folder is shared when entering Chard Root, allowing for fast file sharing. 

<br>

- Includes most compiling tools as a basic toolchain. 
- Uses Sommelier to communicate with ChromeOS' window management and support Desktop Environments, Apps, Games, and more.
- Runs GUI apps with full GPU acceleration including audio support for Chromebooks; including HDMI audio out. 
- Native full screen support, multi-monitor support, and supports ChromeOS window managment gestures. 

<br>

- Does *not* require removing files and includes an uninstaller script to clean up after itself.
- When Installer finishes or exits a log file, 'chariot.log', is created for debugging.
- Can run certain apps directly from Chard in the Host OS (Chard Gentoo + ChromeOS only).

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

- *Chromebooks with 8GB of RAM and 8+ threads can build Chard in 20-60 minutes.*
- *Lower end Chromebooks (2-4 thread Intel, Mediatek 500 series, and older) can expect much longer install times.*

<br>

# Tools: <br>
- Latest Boostrapped Stage3 Gentoo Linux + Linux Kernel
- Emerge
- CRAS

# Chard will use Emerge/Pacman to build: <br>
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
- `chard safe` -- Enter Chard Root without GUI support -- Useful to for emerge or entering Chard prior to finishing Installer.
- `chard reinstall` -- Option 1 for FAST reinstall. Option 2 is a FULL reinstall.
- `chard uninstall` -- Remove Chard. Refresh shell to remove .bashrc entries.
- `chard cat` -- List Portage catalogues.
- `chard help` -- Show help examples.
- `chard chariot` or `chariot` -- Chard's companion tool for setting itself up with a checkpoint system.
- `chard version` -- Check for updates

*Inside Chard Root*
- `SMRT` or `SMRT <1-100>` -- For compiling, auto allocate threads or specify in % how many threads you want to allocate
- `chard_scale display 2` -- Set display scaling to 2x scaling
- `chard_scale cursor 64` -- Set cursor to 64px.

- Refresh a new shell after adjusting scaling.

- Prepend `wx` to an app to try wayland and x11 if unsure.
- `chard mount` to mount a USB device (ignores SSD and USB devices) for UNetBootin.
- `chard unmount` or `exit` to unmount the device.
- Prepend `root` to an app that requires user namespace creation and it might work.
- `exit` -- Leave Chard Root

<br>

### How to use:

- After installer finishes, open a new ChromeOS shell via crosh shell to continue.
- Type in `cr` or `chard_root` to enter Chard Chroot with Sommelier support.
- When running sudo, use `sudo -E` instead.
- When running GParted, make sure to unmount the device in ChromeOS first; otherwise you will to to re-run GParted command.
- `startxfce4` launches a taskbar + app drawer. Right click -> panel -> panel preferences -> uncheck lock and click dots on the sides to drag around.
- Create a launcher in items which then allows for custom app shortcuts.

QEMU Example: 

<br>

`xhost +SI:localuser:root`
`sudo qemu-system-x86_64 \
  -m 4G \
  -cpu host \
  -smp 4 \
  -machine type=q35,accel=kvm \
  -drive file=/home/chronos/ubuntu.qcow2,format=qcow2 \
  -cdrom ~/Downloads/ubuntu.iso \
  -display sdl,gl=on \
  -boot d \
  -name "Ubuntu VM"`

  - -m 4G allocated 4GB of RAM to the VM
  - -smp 4 allocates 4 threads to the VM
  - accel=kvm enables GPU passthrough
  - -display sdl,gl=on enables OpenGL acceleration


  

  

  



<br>

- `startxfce4` to launch a basic app launcher shelf that can be adjusted.
- Do not exit a Chard shell if you have other ones open. Append & at end of an app to run more apps in same shell. 

<br>

### *Known Issues - Some of these issues might not be easily fixed:*

*To Fix Steam Window not rendering:*
<p align="left">
  <img src="https://i.imgur.com/KmxFMkB.png" alt="logo" width="500" />
</p>

- Mouse Capture/Lock in Games is not working.
- Chard Arch cannot run multiple `chard root` shells simultaneously (use xfce4's terminal app)

<br>

- Chrome app shelf is missing icon + pin support. Remedied by customizing xfce4 shelf.
- Entering Chard Root with Sommelier support will have harmless errors generated.

<br>

- Display Scaling support is still in the beginning stages of implementation.
- Mediatek GPU support is currently being worked on.

<br>

- Exiting Chard Root session while others are active is not recommended. Exit them all at once!
- OBS game capture is suggested to run it all in one shell. So run `obs & prismlauncher` for example. 
  
<br>

### Changelog:

- 0.01: `Initial Release` <br><br>
- 0.02: `Added Wayland or X script. Prepend wx to an app if it cannot find display :0. Added header install command for Linux Kernel. Cleaned up Sommelier tmp directory.
Added chard_mount and chard_unmount commands. Enabled KVM kernel flag. Added GParted, UNetBootin and QEMU support. QEMU will use KVM + OpenGL for excellent performance!Now we can format USB's with nearly all file systems and create bootable media in ChromeOS!` <br><br>
- 0.03: `Added Arch Linux support for 10-30x faster install time. Added Steam support (139 only), added native volume controls for Arch.` <br><br>
- 0.04: `Updated to include Steam and Flatpak support for ChromeOS 141+. Chard Arch gets SMRT support` <br><br>
- 0.05: `Isolated Chard forked bubblewrap so other apps will use regular bubblewrap. Added chard unmount command. xfce4 now starts with CHard Arch. Fixed minor bugs.` <br><br>
- 0.06: `Fixed GPU error popup in Mediatek GPU's. (still working on acceleration), Added Firefox support, added SMRT support for yay, fixed Minecraft audio support.`

<br>

### Acknowledgements
- *Google* - Ending official Steam support gave me motivation to learn to run Linux apps inside ChromeOS.
- *Terry Stormchaser* - Spending time testing Borealis alternatives, testing Chard, and providing ideas.
- *DennyL* - Testing Chard and making suggestions.
- *Saragon* - Providing documentation and suggestions.
- *Zhil* - Sending documentation for XFCE4 theme ideas.
- *Sebanc* - Helping me move from Gentoo to Arch and enabling audio for Arch. 
