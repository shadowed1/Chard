<p align="center">
  <img src="https://i.imgur.com/h12e32A.png" alt="logo" width="5000" />
</p>  


# Running a sandboxed Linux Environment inside ChromeOS without a performance hit. 
## *Supports x86_64 & ARM64*
### Goal: Run any Linux program/app natively on all ChromeOS devices. <br>
- *Requires Developer Mode* <br>
- *Untested with Brunch Toolchain, Chromebrew, and dev_install.* <br>
- *Please do not install without a USB recovery as this is under rapid development, mistakes happen, and bugs will exist (for now)!* <br>
- *Requires 8GB of storage, 2GB of RAM, and an internet connection.*
- GUI apps are still being worked on.
- Supports ChromeOS, Ubuntu, Arch, and probably many more. 


<br>

- To install, open up crosh, paste in shell: <br>

<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/chard_download?$(date +%s)")</pre>

<br>

- Chard appends its paths to ChromeOS, ensuring it never overrides system commands. <br>

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
