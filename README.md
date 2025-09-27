<p align="center">
  <img src="https://i.imgur.com/h12e32A.png" alt="logo" width="5000" />
</p>  


# *Chard (Chrome-Arch Development) for x86_64 and ARM64*
## Goal: Run any Linux program/app natively all ChromeOS devices in a semi-sandboxed environment in /usr/local/chard <br>
### Please do not install without a usb recovery as this is under rapid development and mistakes happen.<br> 
*Requires Developer Mode* <br> <br>
*Untested with Brunch Toolchain, Chromebrew, and dev_install* 

To install, open up crosh, type in shell: <br>

<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/chard_download?$(date +%s)")</pre>

# Functioning Tools: <br>
- Boostrapped Stage 3 Gentoo Linux + Linux Headers
- Emerge
- Python
- Git
- GCC
- Make
- CMake
- Meson
- Ninja
- Rust
- OpenSSL
- And Many More

# *After install, open a new shell for all commands to become available.* <br>
`nano` <--- to launch nano. <br>
`gcc` <br>
`python`
`emerge` <-- Requires being in `chard root` <br>
`chard rustc` <br>
`chard cargo` <--- Rust apps must require chard prepend to isolate from system. <br>
`nano` <br>
`ldd` <br>
`file` <br>
`Et Al` <br> <br>
Chard appends its paths to ChromeOS, ensuring it never overrides system commands. <br>
Entering `chard root` will chroot into chard, becoming a fully sandboxed environment.<br><br><br>

*Features an uninstall command, `chard uninstall` to clean up after itself. Does not alter files ouside of /usr/local/* <br>
*When Installer finishes or exits the log file, 'chardbuild.log', is copied to ChromeOS Downloads folder.* <br> 
