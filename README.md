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

- This is a Gentoo Stage3 chroot that builds an independent Linux environment in a semi-sandboxed environment.
- Automated install will build everything needed, even on ChromeOS!
- Tested on a wide array of hardware and distros.

<br>

### Requirements:

<br>

- **Please do not install without a USB recovery as this is under rapid development, mistakes happen, and bugs will exist!**

<br>

- *Requires 8GB of storage, 2GB of RAM, and an internet connection.*
- *CPU Support: x86_64 & ARM64 - CPU must be 64-bit*
- *GPU Support: AMD, Intel, NVIDIA, ARM, Mali, Rockchip, Mediatek, Adreno, & Vivanti*

<br>

- *Requires Developer Mode if on ChromeOS.* <br>
- *Untested with Brunch Toolchain, Chromebrew, and dev_install; but Chard is independent of these tools.*

<br>

### Features:

<br>

- Chard auto-detects the Host's hardware and tailor-builds Gentoo + Kernel around it.
- Includes ability to resume installer if interrupted.

<br>

- Has an intelligent CPU task scheduler for building packages.
- User can customize how many threads Chard can use dynamically. Useful for devices with low memory.

<br>

- GUI apps are still being worked on; but other programs and compiling tools are working.

<br>

- Does *not* alter files ouside of /usr/local/ and a .bashrc entry wrapper that will remove itself on uninstall.
- When Installer finishes or exits the log file, 'chardbuild.log', is copied to home folder.

<br>

# Functioning Tools: <br>
- Latest Boostrapped Stage3 Gentoo Linux + Linux Kernel
- Emerge

# Chard Installer will use Emerge to build: <br>
- Make
- CMake
- Python
- Git
- GCC
- LLVM
- File + LDD
- CMake
- Perl
- Meson
- Ninja
- Rust
- OpenSSL
- Curl
- Flatpak
- And Many More

# Commands (most not listed - on to-do list) <br>
- `chard <binary> <arguments>` -- to run a command wrapped within /usr/local/chard paths outside of chroot.
- `chard root` or `cr` -- Enter Chard Chroot for a fully sandboxed Gentoo environment.
- `chard reinstall` -- Option 1 updates chard scripts to latest version. Option 2 is a full reinstall.
- `chard uninstall` -- Remove Chard. Refresh shell to remove .bashrc entries.
- `chard cat` -- List Portage catalogues.
- `chard help` -- Show help examples.
