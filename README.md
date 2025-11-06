<p align="center">
  <img src="https://i.imgur.com/h12e32A.png" alt="logo" width="5000" />
</p>  

<br>

### How to Install:

<br>

- For **ChromeOS + FydeOS** open crosh, type in `shell` and paste:

<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/chard_download?$(date +%s)")</pre>

<br>

- For **all Linux distros**, open terminal and paste :

<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/Chard_Installer.sh?$(date +%s)")</pre> 

<br>

### About Chard:

<br>

- Run Linux Apps with GUI support natively inside ChromeOS with GPU acceleration!
- This is a Gentoo Stage3 chroot that builds an independent Linux environment in a semi-sandboxed environment.
- Automated install will build everything needed with full hardware detection.
- *Chard is in early development. Bug reports, suggestions, and ideas are greatly appreciated.*
  
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

*Kerbal Space Program:*
<p align="center">
  <img src="https://i.imgur.com/sOLWL73.jpeg" alt="logo" width="1000" />
</p>

<br>

### Features:

<br>

- Chard auto-detects the Host's hardware and builds Gentoo + psuedo-Kernel automatically.
- Includes ability to resume installer if interrupted; even if system shuts down.
- Greatly exceeds Crostini performance and can achieve equal performance to Borealis (RIP) with significantly lower memory overhead.

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
- When Installer finishes or exits the log file, 'chardbuild.log', is copied for viewing/debugging.
- Can run certain apps directly from Chard in the Host OS (ChromeOS only).

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
- *Lower end Chromebooks (2-4 thread Intel, Mediatek 500 series, and older) can expect much longer install times.*

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
- xarchiver
- Gedit
- Codium
- GIMP
- LibreOffice
- Thunar
- Prism Launcher + Minecraft Java
- OBS with Game Capture, Recording, and Streaming support
- Game Emulators
- And too many to test. 

### Commands (Some not listed) <br>
- `chard <binary> <arguments>` -- to run a command wrapped within /usr/local/chard paths outside of chroot (Not fully supported right now).
- `chard root` or `cr` -- Enter Chard Chroot with Sommelier Xwayland GPU acceleration with OpenGL,Vulkan, GUI, and audio support.
- `chard safe` -- Enter Chard Root without GUI support.
- `chard reinstall` -- Option 1 for FAST reinstall. Option 2 is a FULL reinstall.
- `chard uninstall` -- Remove Chard. Refresh shell to remove .bashrc entries.
- `chard cat` -- List Portage catalogues.
- `chard help` -- Show help examples.
- `chard chariot` or `chariot` -- Chard's companion tool for setting itself up with a checkpoint system.
- `chard version` -- Check for updates

*Inside Chard Root*
- `SMRT` or `SMRT <1-100>` -- For compiling, auto allocate threads or specify in % how many threads you want to allocate
- `exit` -- Leave Chard Root
- This is a full Gentoo Linux environment. Read up on Gentoo Linux commands:
<pre>https://wiki.gentoo.org/wiki/Main_Page</pre>

<br>

### How to use:

- After installer finishes, open a new ChromeOS shell via crosh shell to continue.
- Type in `cr` or `chard_root` to enter Chard Chroot with Sommelier support.

<br>

- `startxfce4` to launch a basic app launcher shelf that can be adjusted.
- Do not exit a Chard shell if you have other ones open. Append & at end of an app to run more apps in same shell. 

<br>

### *Known Issues - Some of these issues might not be easily fixed:*

- Bubblewrap support is not functioning. This means Steam, Flatpak, Firefox, and other apps requiring user namespace support are unsupported (for now?).

<br>

- Volume is currently only adjustable via in-app controls.
- PulseAudio can only bind itself to CRAS socket one application at a time. 

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

- 0.01: `Initial Release`

<br>

### Acknowledgements
- *Google* - Ending official Steam support gave me motivation to learn to run Linux apps inside ChromeOS.
- *Terry Stormchaser* - Spending time testing Borealis alternatives, testing Chard, and providing ideas.
- *DennyL* - Testing Chard and making suggestions.
- *Saragon* - Providing documentation and suggestions.
- *Zhil* - Sending documentation for XFCE4 theme ideas. 
