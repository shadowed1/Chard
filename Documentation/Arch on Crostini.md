`Installing Arch Linux in Crostini`

`Thanks to Terry Stormchaser for updating guide for ChromeOS 138`

`https://wiki.archlinux.org/title/Chrome_OS_devices/Crostini`

`Using termina without a password`

`ctrl-alt-t:`
```
vmc stop termina

vmc destroy termina

vmc start termina
```
```
lxc remote remove images

lxc remote add images https://images.lxd.canonical.com/ --protocol=simplestreams

lxc launch images:archlinux arch --config security.privileged=true

lxc start arch

lxc exec arch -- bash
```
```

sudo sed -i '/^# %wheel ALL=(ALL:ALL) ALL/s/^# //' /etc/sudoers && sudo visudo -c

sudo sed -i '/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/s/^# //' /etc/sudoers && sudo visudo -c

sudo nano /etc/pacman.conf

Uncomment:

[multilib]
Include = /etc/pacman.d/mirrorlist

useradd -m -u 1000 -G wheel termina

passwd -d termina

usermod -aG wheel termina

exit
```
```
lxc exec arch -- sudo -i -u termina

sudo pacman -Syu --noconfirm \
  && sudo pacman -S --needed --noconfirm base-devel git \
  && sudo chown termina /home \
  && sudo mkdir -p /home/termina \
  && cd ~ \
  && git clone https://aur.archlinux.org/yay.git \
  && cd yay \
  && makepkg -si --noconfirm


{ printf '3\nn\n'; yes y; } | yay -S cros-container-guest-tools-git

yes | yay -S wayland && yes | yay -S xorg-xwayland && yes | yay -S dhclient



# Optional if no network issues; I recommend installing
# dhclient just in-case:
# If no network later on, run this:

sudo dhcpcd eth0 && sudo systemctl disable systemd-networkd && sudo systemctl disable systemd-resolved && sudo unlink /etc/resolv.conf && sudo touch /etc/resolv.conf && sudo systemctl enable dhclient@eth0 && sudo systemctl start dhclient@eth0

exit
```
```
lxc console arch

enter key & login

systemctl --user enable sommelier@0.service && systemctl --user enable sommelier@1.service && systemctl --user enable sommelier-x@1.service && systemctl --user enable sommelier-x@0.service


```
`ctrl-a q to exit`

```
lxc stop --force arch 

lxc rename arch penguin

lxc start penguin
```
```
Open GUI Linux app, launch Penguin and let it crash!

Right-click the terminal icon and stop linux

Re-open GUI Linux app, launch penguin!
```
```
Enable Audio in Arch - Launch via GUI:

cp -rT /etc/skel/.config/pulse ~/.config/pulse

yay -S pipewire && sudo nano /etc/pipewire/pipewire.conf.d/crostini-audio.conf

Copy paste this into, ctrl-o, enter, ctrl-x:

context.objects = [
    { factory = adapter
        args = {
            factory.name           = api.alsa.pcm.sink
            node.name              = "Virtio Soundcard Sink"
            media.class            = "Audio/Sink"
            api.alsa.path          = "hw:0,0"
            audio.channels         = 2
            audio.position         = "FL,FR"
        }
    }
    { factory = adapter
        args = {
            factory.name           = api.alsa.pcm.source
            node.name              = "Virtio Soundcard Source"
            media.class            = "Audio/Source"
            api.alsa.path          = "hw:0,0"
            audio.channels         = 2
            audio.position         = "FL,FR"
        }
    }
]

reboot
```
```
########################################################

RESTORING IMAGE

vmc start termina then lxc config set penguin security.privileged true

##########################################################
```
```
Vulkan Time

yay -S --noconfirm \
  vulkan-virtio \
  lib32-vulkan-virtio \
  vulkan-icd-loader \
  lib32-vulkan-icd-loader \
  vulkan-mesa-layers \
  lib32-vulkan-mesa-layers

sudo pacman -S vulkan-tools
 
sudo nano /etc/tmpfiles.d/dri-symlinks.conf

L /dev/dri/by-path/pci-0000:00:02.0-card   - - - - ../card0
L /dev/dri/by-path/pci-0000:00:02.0-render - - - - ../renderD128

sudo systemd-tmpfiles --create

# Fix me

sudo chown root:video /dev/dri/card0
sudo chmod 660 /dev/dri/card0
sudo chown root:render /dev/dri/renderD128
sudo chmod 666 /dev/dri/renderD128

# Fix commands above to be persistent on boot

reboot
```
```
yay -S --noconfirm libva libva-utils

sudo pacman -S --needed base-devel git meson ninja pkg-config python

sudo pacman -S libva libva-utils libdrm
```

sudo mv /usr/share/vulkan/explicit_layer.d/VkLayer_INTEL_nullhw.json /usr/share/vulkan/explicit_layer.d/VkLayer_INTEL_nullhw.json.disabled

sudo mv /usr/share/vulkan/explicit_layer.d/VkLayer_MESA_vram_report_limit.json /usr/share/vulkan/explicit_layer.d/VkLayer_MESA_vram_report_limit.json.disabled

