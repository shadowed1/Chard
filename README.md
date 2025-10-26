<p align="center">
  <img src="https://i.imgur.com/h12e32A.png" alt="logo" width="5000" />
</p>  


# Running a sandboxed Linux Environment inside ChromeOS without a performance hit. 
## *CPU Support: x86_64 & ARM64 - CPU must be 64-bit* <br>
## *GPU Support: AMD, Intel, NVIDIA, ARM, Mali, Rockchip, Mediatek, Adreno, Vivanti, and more if needed.
## Goal: Run any Linux program/app natively on all ChromeOS devices. <br>
### This is a Gentoo Stage3 chroot that builds an optimized Gentoo environment in a semi-sandboxed environment. <br>
### Independent of Host OS with exception of basic tools like curl, cd, tar, etc. 

<br>

- Chard auto-detects the Host's hardware and tailor-builds Gentoo + Kernel around it.
- Supports 
- Chard has ability to resume installer if interrupted.
- Includes an intelligent CPU task scheduler for building packages.
- User can customize how many threads Chard can use dynamically. Useful for devices with low memory. 
- GUI apps are still being worked on; but other programs and compiling tools are working great.
- Supports ChromeOS, Ubuntu, Arch, and probably many more. 

<br>

- *Requires Developer Mode* <br>
- *Untested with Brunch Toolchain, Chromebrew, and dev_install.* <br>
- *Please do not install without a USB recovery as this is under rapid development, mistakes happen, and bugs will exist (for now)!* <br>
- *Requires 8GB of storage, 2GB of RAM, and an internet connection.*

<br>

## Download:

- For ChromeOS open crosh, type in `shell` and paste: <br>

<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/chard_download?$(date +%s)")</pre>

<br>

- For all Linux distros supporting Bash, and ChromeOS with sudo in shell, open terminal and paste : <br>
<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/Chard_Installer.sh?$(date +%s)")</pre> 

<br>

- Installer will be fully automated. It will detect the system's hardware and build Gentoo around it.

<br>

- Chard appends its paths to Host OS, ensuring it never overrides system commands. <br>


# Functioning Tools: <br>
- Latest Boostrapped Stage3 Gentoo Linux + Linux Kernel
- Emerge

# Use Emerge to build: <br>

- Make
- CMake
- Python
- Git
- GCC
- File + LDD
- CMake
- Perl
- Meson
- Ninja
- Rust
- OpenSSL
- Curl
- And Many More

# Commands <br>
- `chard <binary> <arguments>` to run a command wrapped within /usr/local/chard paths outside of chroot.
- `chard root` Enter Chard Chroot for a fully sandboxed Gentoo environment.
- `chard reinstall` Option 1 updates chard scripts to latest version. Option 2 is a full reinstall.
- `chard uninstall` Remove Chard. Refresh shell to remove .bashrc entries.
- `chard cat` List Portage catalogues.
- `chard help` Show help examples. 

- Does *not* alter files ouside of /usr/local/ <br>
- When Installer finishes or exits the log file, 'chardbuild.log', is copied to ChromeOS Downloads folder.* <br> 
- Chard Installer  runs: emerge --sync near the end of install to finish setup. <br>
- Please do not run emerge --sync more than once a day due to this built-in Emerge warning: <br>

`Please note: common gentoo-netiquette says you should not
sync more than once a day.  Excessive requests may lead
automatic temporary bans on rsync.gentoo.org service.`
