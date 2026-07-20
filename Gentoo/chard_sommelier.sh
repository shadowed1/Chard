#!/bin/bash
# chard_sommelier-x
# version 4
CHARD_HOME=$(cat /.chard_home)
CHARD_USER=$(cat /.chard_user)
XDG_RUNTIME_DIR=$(cat /.xdg_runtime_dir)
ACCELERATORS=""
WINDOWED_ACCELERATORS=""
FORCE_DRM_DEVICE="/dev/dri/renderD128"
WAYLAND_DISPLAY="$XDG_RUNTIME_DIR/wayland-0"

XWAYLAND_PATH=""

for path in \
    /usr/bin/Xwayland \
    /usr/libexec/Xwayland
do
    if [[ -x "$path" ]]; then
        XWAYLAND_PATH="$path"
        break
    fi
done

if [[ -z "$XWAYLAND_PATH" ]]; then
    XWAYLAND_PATH=$(find /usr /opt /bin -type f -name Xwayland -executable 2>/dev/null | head -n1)
fi

UNASSIGNED_ACCELERATORS=""
#
# These variables are placeholders. Do not remove them, read carefully:
# if you wish to add a shortcut, ensure it meets the requirements outlined
# below, then replace either the "CHROMEBOOK_" or "UNASSIGNED_" prefix of
# the corresponding entry with "WINDOWED_" so it's handled by the host
# compositor when the focused window is windowed, but not while it is
# fullscreen. Rename it "ACCELERATORS" instead if you want your shortcut
# to be always consumed by the host compositor, unconditionally preventing
# Linux Programs from overriding it whether they're windowed
# or fullscreen. Both are included for completeness.
#
CHROMEBOOK_ACCELERATORS=""
#
# By default these shortcuts contain at least one Chrome OS system
# key and are handled as special functions directly, and are always
# consumed regardless of whether they trigger an accelerator. Typically
# these are found on the top row of our keyboard, but you will notice
# that it doesn't include the escape, back, forward, reload, or print
# screen keys, so it does not represent all of them. The reason this index
# exists in the first place is if you wanted to add a valid accelerator
# here, then the shortcut you have must not already contain one of these:
#
# VKEY_ASSISTANT             // Launcher/Search
# VKEY_ZOOM                  // Fullscreen button
# VKEY_MEDIA_LAUNCH_APP1     // Overview button
# VKEY_OEM_103               // KEYCODE_MEDIA_REWIND
# VKEY_OEM_104               // KEYCODE_MEDIA_FAST_FORWARD
# VKEY_F13                   // Lock button on some chromebooks emit F13
# VKEY_BRIGHTNESS_DOWN
# VKEY_BRIGHTNESS_UP
# VKEY_KBD_BRIGHTNESS_DOWN
# VKEY_KBD_BRIGHTNESS_UP
# VKEY_VOLUME_MUTE
# VKEY_VOLUME_DOWN
# VKEY_VOLUME_UP
# VKEY_POWER
# VKEY_SLEEP
# VKEY_PRIVACY_SCREEN_TOGGLE
# VKEY_SETTINGS
# VKEY_DO_NOT_DISTURB
# VKEY_MEDIA_NEXT_TRACK
# VKEY_MEDIA_PAUSE
# VKEY_MEDIA_PLAY
# VKEY_MEDIA_PLAY_PAUSE
# VKEY_MEDIA_PREV_TRACK
# VKEY_MEDIA_STOP
#
# Basically what this means is that they are always reserved,
# and any accelerator that contains a key from this list doesn't
# need to be handled even if it's modified. There are some additional
# nuances here, but the takeaway should be that these keys cannot
# be added in the first place. The placeholder for these is only
# indexed because we can also support a custom accelerator for it,
# as long as it's added through the UI; it can be configured here
# as well. Therefore it would only be valid if it doesn't contain
# the special keys outlined above, since we are able to assign it.
# We also include key shortcuts that cannot be modified so that
# they may also be reserved; however, some locked shortcuts are
# still excluded because they would be inapplicable, in that
# case it means the shortcut is locked and is reserved anyway,
# or it's locked and has a specific use case in either the
# browser or a specific app, like MyFiles.
#
###########################################################################################################################################################################
# General controls                                                          < Excluded: 0 > # Description                                                                 #
###########################################################################################################################################################################
ACCELERATORS="${ACCELERATORS}Super_L,"                                                      # Open/close launcher                                                         #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}Super_L,"                                    # Open/close launcher                                                         #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Overview mode                                                               #
ACCELERATORS="${ACCELERATORS}<Alt><Shift>s,"                                                # Open Quick Settings                                                         #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt><Shift>s,"                              # Open Quick Settings                                                         #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Open/close calender                                                         #
ACCELERATORS="${ACCELERATORS}<Alt><Shift>n,"                                                # Open notifications                                                          #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt><Shift>n,"                              # Open notifications                                                          #
ACCELERATORS="${ACCELERATORS}Print,"                                                        # Take full screenshot or screen recording                                    #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}Print,"                                      # Take full screenshot or screen recording                                    #
ACCELERATORS="${ACCELERATORS}<Alt>Print,"                                                   # Take partial screenshot or screen recording                                 #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>Print,"                                 # Take partial screenshot or screen recording                                 #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Take window screenshot or screen recording                                  #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Stop screen recording                                                       #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Lock device                                                                 #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Put device in sleep mode                                                    #
ACCELERATORS="${ACCELERATORS}<Control><Shift>q,"                                            # Sign out                                                                    #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Shift>q,"                          # Sign out                                                                    #
ACCELERATORS="${ACCELERATORS}<Control><Alt>period,"                                         # Switch to next user                                                         #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Alt>period,"                       # Switch to next user                                                         #
ACCELERATORS="${ACCELERATORS}<Control><Alt>comma,"                                          # Switch to previous user                                                     #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Alt>comma,"                        # Switch to previous user                                                     #
UNASSIGNED_ACCELERATORS="${UNASSIGNED_ACCELERATORS},"                                       # Open/close Google assistant                                                 #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Search my screen                                                            #
UNASSIGNED_ACCELERATORS="${UNASSIGNED_ACCELERATORS},"                                       # Turn on/off do not disturb                                                  #
UNASSIGNED_ACCELERATORS="${UNASSIGNED_ACCELERATORS},"                                       # Turn on/off camera access                                                   #
###########################################################################################################################################################################
# Apps                                                                      < Excluded: 2 > # Description                                                                 #
###########################################################################################################################################################################
ACCELERATORS="${ACCELERATORS}<Alt><Shift>m,"                                                # Open MyFiles app                                                            #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt><Shift>m,"                              # Open MyFiles app                                                            #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Open Key Shortcuts app                                                      #
UNASSIGNED_ACCELERATORS="${UNASSIGNED_ACCELERATORS},"                                       # Open Calculator app                                                         #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Open Key Diagnostics app                                                    #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Open "Help" in Explore app                                                  #
ACCELERATORS="${ACCELERATORS}<Alt><Shift>i,"                                                # Open Feedback tool                                                          #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt><Shift>i,"                              # Open Feedback tool                                                          #
ACCELERATORS="${ACCELERATORS}<Alt>1,"                                                       # Click or tap shelf icon 1                                                   #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>1,"                                     # Click or tap shelf icon 1                                                   #
ACCELERATORS="${ACCELERATORS}<Alt>2,"                                                       # Click or tap shelf icon 2                                                   #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>2,"                                     # Click or tap shelf icon 2                                                   #
ACCELERATORS="${ACCELERATORS}<Alt>3,"                                                       # Click or tap shelf icon 3                                                   #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>3,"                                     # Click or tap shelf icon 3                                                   #
ACCELERATORS="${ACCELERATORS}<Alt>4,"                                                       # Click or tap shelf icon 4                                                   #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>4,"                                     # Click or tap shelf icon 4                                                   #
ACCELERATORS="${ACCELERATORS}<Alt>5,"                                                       # Click or tap shelf icon 5                                                   #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>5,"                                     # Click or tap shelf icon 5                                                   #
ACCELERATORS="${ACCELERATORS}<Alt>6,"                                                       # Click or tap shelf icon 6                                                   #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>6,"                                     # Click or tap shelf icon 6                                                   #
ACCELERATORS="${ACCELERATORS}<Alt>7,"                                                       # Click or tap shelf icon 7                                                   #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>7,"                                     # Click or tap shelf icon 7                                                   #
ACCELERATORS="${ACCELERATORS}<Alt>8,"                                                       # Click or tap shelf icon 8                                                   #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>8,"                                     # Click or tap shelf icon 8                                                   #
ACCELERATORS="${ACCELERATORS}<Alt>9,"                                                       # Click or tap last icon on shelf                                             #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>9,"                                     # Click or tap last icon on shelf                                             #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn on/off menu to resize lock mode                                        #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Open task manager                                                           #
ACCELERATORS="${ACCELERATORS}<Control><Alt>t,"                                              # Open Crosh window                                                           #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Alt>t,"                            # Open Crosh window                                                           #
UNASSIGNED_ACCELERATORS="${UNASSIGNED_ACCELERATORS},"                                       # Toggle Gemini                                                               #
###########################################################################################################################################################################
# Device                                                                    < Excluded: 0 > # Description                                                                 #
###########################################################################################################################################################################
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn volume up                                                              #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn volume down                                                            #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Mute sound                                                                  #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn on/off microphone                                                      #
UNASSIGNED_ACCELERATORS="${UNASSIGNED_ACCELERATORS},"                                       # Play media                                                                  #
UNASSIGNED_ACCELERATORS="${UNASSIGNED_ACCELERATORS},"                                       # Pause media                                                                 #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Play or pause media                                                         #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Go to next track                                                            #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Go to previous track                                                        #
UNASSIGNED_ACCELERATORS="${UNASSIGNED_ACCELERATORS},"                                       # Fast forward media                                                          #
ACCELERATORS="${ACCELERATORS}<Alt><Shift>v,"                                                # Focus on the picture-in-picture window                                      #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt><Shift>v,"                              # Focus on the picture-in-picture window                                      #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS}"                                        # Switch between the maximum or current size of the picture-in-picture window #
###########################################################################################################################################################################
# Input                                                                     < Excluded: 0 > # Description                                                                 #
###########################################################################################################################################################################
UNASSIGNED_ACCELERATORS="${UNASSIGNED_ACCELERATORS},"                                       # Turn on/off keyboard backlight                                              #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn keyboard backlight brightness up                                       #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn keyboard backlight brightness down                                     #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Show list of available input methods                                        #
ACCELERATORS="${ACCELERATORS}<Control><Shift>space,"                                        # Switch to next available input method                                       #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Shift>space,"                      # Switch to next available input method                                       #
ACCELERATORS="${WINDOWED_ACCELERATORS}<Control>space,"                                      # Switch to last language selected                                            #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control>space,"                             # Switch to last language selected                                            #
ACCELERATORS="${ACCELERATORS}<Alt><Shift>p,"                                                # Toggle stylus tools                                                         #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt><Shift>p,"                              # Toggle stylus tools                                                         #
###########################################################################################################################################################################
# Display                                                                   < Excluded: 0 > # Description                                                                 #
###########################################################################################################################################################################
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn internal display brightness up                                         #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn internal display brightness down                                       #
ACCELERATORS="${ACCELERATORS}<Control><Shift>minus,"                                        # Zoom out                                                                    #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Shift>minus,"                      # Zoom out                                                                    #
ACCELERATORS="${ACCELERATORS}<Control><Shift>plus,"                                         # Zoom in                                                                     #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Shift>plus,"                       # Zoom in                                                                     #
ACCELERATORS="${ACCELERATORS}<Control><Shift>0,"                                            # Zoom reset                                                                  #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Shift>0,"                          # Zoom reset                                                                  #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Mirror monitors                                                             #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Swap primary monitor                                                        #
ACCELERATORS="${ACCELERATORS}<Control><Shift>XF86Reload,"                                   # Rotate screen 90 degrees clockwise                                          #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Shift>XF86Reload,"                 # Rotate screen 90 degrees clockwise                                          #
###########################################################################################################################################################################
# Browser                                                                  < Excluded: 52 > # Description                                                                 #
###########################################################################################################################################################################
ACCELERATORS="${ACCELERATORS}<Control>t,"                                                   # Open a new tab                                                              #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control>t,"                                 # Open a new tab                                                              #
ACCELERATORS="${ACCELERATORS}<Control>n,"                                                   # Open a new tab in a new window                                              #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control>n,"                                 # Open a new tab in a new window                                              #
ACCELERATORS="${ACCELERATORS}<Control><Shift>n,"                                            # Open a new tab in a new incognito window                                    #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Shift>n,"                          # Open a new tab in a new incognito window                                    #
ACCELERATORS="${ACCELERATORS}<Control><Shift>t,"                                            # Reopen the last tab or window closed                                        #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Shift>t,"                          # Reopen the last tab or window closed                                        #
###########################################################################################################################################################################
# Text                                                                     < Excluded: 21 > # Description                                                                 #
###########################################################################################################################################################################
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Open Emoji Picker                                                           #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Quick Insert                                                                #
###########################################################################################################################################################################
# Windows                                                                   < Excluded: 0 > # Description                                                                 #
###########################################################################################################################################################################
ACCELERATORS="${ACCELERATORS}<Alt>tab,"                                                     # Cycle forward through windows                                               #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>tab,"                                   # Cycle forward through windows                                               #
ACCELERATORS="${ACCELERATORS}<Alt><Shift>tab,"                                              # Cycle backwards between windows                                             #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt><Shift>tab,"                            # Cycle backwards between windows                                             #
ACCELERATORS="${ACCELERATORS}<Alt>equal,"                                                   # Maximize window                                                             #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>equal,"                                 # Maximize window                                                             #
ACCELERATORS="${ACCELERATORS}<Alt>minus,"                                                   # Minimize window                                                             #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>minus,"                                 # Minimize window                                                             #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Enter or exit fullscreen                                                    #
ACCELERATORS="${ACCELERATORS}<Shift><Control>w,"                                            # Close the current window                                                    #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Shift><Control>w,"                          # Close the current window                                                    #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Open window layout options                                                  #
ACCELERATORS="${ACCELERATORS}<Alt>bracketleft,"                                             # Pin window to the left                                                      #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>bracketleft,"                           # Pin window to the left                                                      #
ACCELERATORS="${ACCELERATORS}<Alt>bracketright,"                                            # Pin window to the right                                                     #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt>bracketright,"                          # Pin window to the right                                                     #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Move active window between displays                                         #
ACCELERATORS="${ACCELERATORS}XF86Back,"                                                     # Minimize top window when there's no back history in Chrome                  #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}XF86Back,"                                   # Minimize top window when there's no back history in Chrome                  #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Group or ungroup two side-by-side windows                                   #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Toggle floating                                                             #
###########################################################################################################################################################################
# Desks                                                                     < Excluded: 0 > # Description                                                                 #
###########################################################################################################################################################################
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Create new desk                                                             #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Remove current desk                                                         #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Activate desk on left                                                       #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Activate desk on right                                                      #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Move active window to desk on left                                          #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Move active window to desk on right                                         #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Dock window to the left                                                     #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Go to desk 1                                                                #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Go to desk 2                                                                #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Go to desk 3                                                                #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Go to desk 4                                                                #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Go to desk 5                                                                #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Go to desk 6                                                                #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Go to desk 7                                                                #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Go to desk 8                                                                #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Assign active window to all desks                                           #
###########################################################################################################################################################################
# Accessibility                                                            < Excluded: 10 > # Description                                                                 #
###########################################################################################################################################################################
ACCELERATORS="${ACCELERATORS}<Control><Alt>z,"                                              # Turn on/off ChromeVox (spoken feedback)                                     #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Alt>z,"                            # Turn on/off ChromeVox (spoken feedback)                                     #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # When turned on, pause and resume mouse keys                                 #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn on/off dictation (type with your voice)                                #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn on Select-to-Speak                                                     #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn on high contrast mode                                                  #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn magnifier on or off                                                    #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Turn fullscreen magnifier on or off                                         #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Zoom in when magnifier is on                                                #
CHROMEBOOK_ACCELERATORS="${CHROMEBOOK_ACCELERATORS},"                                       # Zoom out when magnifier is on                                               #
UNASSIGNED_ACCELERATORS="${UNASSIGNED_ACCELERATORS},"                                       # Open accessibility options                                                  #
ACCELERATORS="${ACCELERATORS}<Control>XF86Back,"                                            # Switch focus between areas                                                  #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control>XF86Back,"                          # Switch focus between areas                                                  #
ACCELERATORS="${ACCELERATORS}<Control>XF86Forward,"                                         # Switch focus between areas                                                  #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control>XF86Forward,"                       # Switch focus between areas                                                  #
ACCELERATORS="${ACCELERATORS}<Control><Shift>XF86Back,"                                     # Switch focus between areas                                                  #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Shift>XF86Back,"                   # Switch focus between areas                                                  #
ACCELERATORS="${ACCELERATORS}<Control><Shift>XF86Forward,"                                  # Switch focus between areas                                                  #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Control><Shift>XF86Forward,"                # Switch focus between areas                                                  #
ACCELERATORS="${ACCELERATORS}<Alt><Shift>l,"                                                # Highlight Launcher button on shelf                                          #
WINDOWED_ACCELERATORS="${WINDOWED_ACCELERATORS}<Alt><Shift>l,"                              # Highlight Launcher button on shelf                                          #
###########################################################################################################################################################################

SOMMELIER=(
    sommelier
    -X
    --glamor
    --force-drm-device="$FORCE_DRM_DEVICE"
    --display="$WAYLAND_DISPLAY"
    --noop-driver
    --fullscreen-mode=plain
    --direct-scale
    --stable-scaling
    --enable-xshape
    --sd-notify=READY=1
    --allow-xwayland-emulate-screen-pos-size
    --only-client-can-exit-fullscreen
    --application-id-x11-property=STEAM_GAME
    --application-id=org.chromium.arc.session.1
    --accelerators="$ACCELERATORS"
    --windowed-accelerators="$WINDOWED_ACCELERATORS"
    --frame-color="#202020"
    --enable-linux-dmabuf
    --xwayland-path=$XWAYLAND_PATH
    --vm-identifier=termina
)

   # TODO: This could benefit from some reconsideration/more work
   "${SOMMELIER[@]}" -- bash -c '
   sleep 0.1
    export DISPLAY=$(ls /tmp/.X11-unix | sed "s/^X/:/" | head -n1)
    [ -f ~/.bashrc ] && source ~/.bashrc
    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
        eval "$(dbus-launch --sh-syntax)"
    fi
    cd ~/
    powercontrol-gui 2>/dev/null &
    sleep 0.2
    pipewire 2>/dev/null &
    sleep 0.2
    pulseaudio 2>/dev/null &
    sleep 0.2
    chardwire 2>/dev/null &
    sleep 0.2
    color_reset 2>/dev/null &
    sleep 0.2
    xfce4-terminal 2>/dev/null &
    sleep 0.2
    chard_launch_daemon 2>/dev/null &
    sleep 0.2
    exec bash
'
error_color
sudo setfacl -Rb /root 2>/dev/null
killall -9 chardwire 2>/dev/null

if [ -f /tmp/.pulseaudio_pid ]; then
    kill "$(cat /tmp/.pulseaudio_pid)" 2>/dev/null
    rm -f /tmp/.pulseaudio_pid
fi
