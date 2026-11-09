#!/bin/bash
if [ ! -e /.chard_home ] || [ -e /etc/sudoers.d/timeout ]; then
    sudo -v
else
    echo 'Defaults timestamp_timeout=60' | sudo tee /etc/sudoers.d/timeout >/dev/null
    sudo chmod 440 /etc/sudoers.d/timeout
    sudo visudo -cf /etc/sudoers.d/timeout
    sudo -v
fi
