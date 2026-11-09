sudo tee /bin/chard_flatpak >/dev/null <<'EOF'
#!/bin/bash
export PATH=/usr/local/bubblepatch/bin:$PATH
xhost +SI:localuser:root
sudo setfacl -Rm u:root:rwx /run/chrome 2>/dev/null
sudo setfacl -Rm u:1000:rwx /run/chrome 2>/dev/null
sudo -E /usr/bin/env bash -c '
    exec /usr/bin/flatpak "$@"
' -- "$@"
sudo setfacl -Rb /run/chrome 2>/dev/null
EOF
