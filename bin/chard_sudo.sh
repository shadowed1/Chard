#!/bin/bash
# Cache Sudo
echo 'Defaults timestamp_timeout=60' | sudo tee /etc/sudoers.d/timeout >/dev/null && sudo chmod 440 /etc/sudoers.d/timeout && sudo -v
