<p align="center">
  <img src="https://i.imgur.com/h12e32A.png" alt="logo" width="5000" />
</p>  

<br>

*Notice: Chard is in early development and has bugs. Suggestions and testing are greatly appreciated.* 

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

- This is a Gentoo Stage3 chroot that builds an independent Linux environment in a semi-sandboxed environment.
- Automated install will build everything needed, even on ChromeOS!
- Tested on a wide array of hardware and distros - but focusing on ChromeOS.

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

- *Chromebooks with 8GB of RAM and 8+ threads can build Chard in 4-8 hours.*
- *Lower end Chromebooks (4 thread Intel, Mediatek 500 series, and older) can expect much longer install times.*

<br>

### Features:

<br>

- Chard auto-detects the Host's hardware and builds Gentoo + psuedo-Kernel automatically.
- Includes ability to resume installer if interrupted; even if system shuts down.

<br>

- Has an intelligent CPU task scheduler for building packages.
- User can customize how many threads Chard can use dynamically. Useful for devices with low memory.
- Hardware detection scripts allows compilers to enable native architectural tweaks.

<br>

- Supports running Wayland/X11 apps directly in chroot.
- Uses Sommelier communicate with ChromeOS' and support X11 Desktop Environments and Apps.
- Runs GUI apps with full GPU acceleration.

<br>

- Does *not* alter files ouside of /usr/local/ and a .bashrc entry wrapper that will remove itself on uninstall.
- When Installer finishes or exits the log file, 'chardbuild.log', is copied to home folder.
- Can run certain apps directly from Chard in the Host OS; with libraries being slowly validated. 

<br>

# Functioning Tools: <br>
- Latest Boostrapped Stage3 Gentoo Linux + Linux Kernel
- Emerge

# Chard Installer will use Emerge to build: <br>
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
- Flatpak (broken)
- Sommelier
- Wayland
- X11
- XFCE4
- Gedit
- KDE Plasma
- Brave Browser!
- And Many More

# Commands (most not listed - on to-do list) <br>
- `chard <binary> <arguments>` -- to run a command wrapped within /usr/local/chard paths outside of chroot (needs rework).
- `chard root` or `cr` -- Enter Chard Chroot for a fully sandboxed Gentoo environment.
- `chard reinstall` -- Option 1 updates chard scripts to latest version. Option 2 is a full reinstall.
- `chard uninstall` -- Remove Chard. Refresh shell to remove .bashrc entries.
- `chard cat` -- List Portage catalogues.
- `chard help` -- Show help examples.

*Inside Chard Root*
- `SMRT` or `SMRT <1-100>` -- For compiling, auto allocate threads or specify in % how many threads you want to allocate.
- `chariot` -- Chard's companion tool for setting itself up with a checkpoint system.
- `w` -- Launch into a full Sommelier Xwayland environment. (Placeholder name)
- `x vlc` -- Prepending `x` to an app you want to run will run it in an Xwayland environment. (Placeholder name)
