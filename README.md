# Chard - Chrome-Arch Development
## Goal: Run any Linux program/app natively in ChromeOS in a semi-sandboxed environment in /usr/local/chard <br>
### Please do not install without a usb recovery as this is under rapid development and mistakes happen.<br>
*Requires Developer Mode* <br>
*After install, chard commands will be available, along with many apps; like nano.* <br>
`nano` <--- to launch nano. <br>
`gcc` <br>
`python` <br>
`chard emerge` <--- prepend chard to command of your choice to have a custom wrapper only use paths in `/usr/local/chard` <br>
`Et Al` <br>

Chard appends its paths to ChromeOS, ensuring it never overrides system commands. <br> <br>

To install, open up crosh, type in shell: <br>

<pre>bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/chard_download?$(date +%s)")</pre>
