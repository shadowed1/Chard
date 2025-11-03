<p align="center">
  <img src="https://i.imgur.com/h12e32A.png" alt="logo" width="5000" />
</p>  

<br>

### How to Install:

<br>

- For **ChromeOS** open crosh, type in `shell` and paste:

<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/chard_download?$(date +%s)")</pre>

<br>

- For **all Linux distros**, open terminal and paste :

<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/Chard_Installer.sh?$(date +%s)")</pre> 

<br>

### What is this?

<br>

- Run Linux Apps with GUI support natively inside ChromeOS with GPU acceleration!
- This is a Gentoo Stage3 chroot that builds an independent Linux environment in a semi-sandboxed environment.
- Automated install will build everything needed with full hardware detection.
  
<br>

### Examples:

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

*Kerbal Space Program:*
<p align="center">
  <img src="https://i.imgur.com/sOLWL73.jpeg" alt="logo" width="1000" />
</p>  

<br>

### Features:

<br>

- Chard auto-detects the Host's hardware and builds Gentoo + psuedo-Kernel automatically.
- Includes ability to resume installer if interrupted; even if system shuts down.
- Greatly exceeds Crostini performance and can achieve equal performance to Borealis with far less overhead.


<br>

- Intelligent CPU task scheduler for building packages.
- User can customize how many threads Chard can use dynamically. Useful for devices with low memory.
- Hardware detection scripts allows compilers to enable native architectural tweaks.

<br>

- Supports running Wayland/X11 apps directly in chroot.
- Uses Sommelier to communicate with ChromeOS and support X11 Desktop Environments, Apps and Games.
- Runs GUI apps with full GPU acceleration including audio support for Chromebooks.
- Native full screen support, multi-monitor support, and supports ChromeOS window managment gestures. 

<br>

- Does *not* require removing files and includes an uninstaller script to clean up after itself.
- When Installer finishes or exits the log file, 'chardbuild.log', is copied for viewing/debugging.
- Can run certain apps directly from Chard in the Host OS; with libraries being whitelisted. 

<br>

### Requirements:

<br>

- **Please do not install without a USB recovery as this is under rapid development, mistakes happen, and bugs will exist!**

<br>

- *Intel CPU's are recommended to enable hyperthreading in `chrome://flags` via Scheduler setting.*
- *Building apps will heat up your system and require delayed/disabled sleep times!*

<br>

- *ChromeOS_PowerControl is recommended for custom fan curve, custom CPU clock speed curve, and enabling custom sleep thresholds for ChromeOS users:*
<pre>https://github.com/shadowed1/ChromeOS_PowerControl/blob/main/README.md</pre>

<br>

- *Requires 8GB of storage, 2GB of RAM, and an internet connection.*
- *CPU Support: x86_64 & ARM64 - CPU must be 64-bit*
- *GPU Support: AMD, Intel, NVIDIA, ARM, Mali, Rockchip, Mediatek, Adreno, & Vivanti*

<br>

- *Requires Developer Mode if on ChromeOS.* <br>
- *Untested with Brunch Toolchain, Chromebrew, and dev_install; but Chard is independent of these tools.*

<br>

- *Chromebooks with 8GB of RAM and 8+ threads can build Chard in 3-6 hours.*
- *Lower end Chromebooks (4 thread Intel, Mediatek 500 series, and older) can expect much longer install times.*

<br>

# Functioning Tools: <br>
- Latest Boostrapped Stage3 Gentoo Linux + Linux Kernel
- Emerge
- Sommelier
- CRAS

# Chard can use Emerge to build: <br>
- Make
- CMake
- Curl with OpenSSL
- GCC
- Python
- Git
- File + LDD
- CMake
- Perl
- Meson
- Ninja
- Rust
- OpenSSL
- LLVM
- Clang
- Mesa
- Vulkan + Vulkan Tools
- Flatpak (broken for now)
- Sommelier
- Wayland
- X11
- XFCE4
- Gedit
- VLC
- KDE Plasma
- Brave Browser
- xarchiver
- Codium
- Prism Launcher + Minecraft
- And Many More

# Commands (most not listed - on to-do list) <br>
- `chard <binary> <arguments>` -- to run a command wrapped within /usr/local/chard paths outside of chroot (needs rework).
- `chard root` or `cr` -- Enter Chard Chroot for a fully sandboxed Gentoo environment.
- `chard reinstall` -- Option 1 updates chard scripts to latest version. Option 2 is a full reinstall.
- `chard uninstall` -- Remove Chard. Refresh shell to remove .bashrc entries.
- `chard cat` -- List Portage catalogues.
- `chard help` -- Show help examples.
- `chard chariot` or `chariot` -- Chard's companion tool for setting itself up with a checkpoint system.

*Inside Chard Root*
- `SMRT` or `SMRT <1-100>` -- For compiling, auto allocate threads or specify in % how many threads you want to allocate.
- `chariot` -- Chard's companion tool for setting itself up with a checkpoint system.
- `chard_sommelier` -- Launch into a full Sommelier Xwayland environment. (Placeholder name)
- `x vlc` -- Prepending `x` to an app you want to run will run it in an Xwayland environment. (Placeholder name)
