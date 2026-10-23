# Install Tailscale in Chard normally.
sudo pacman -Syy
sudo pacman -S tailscale

# In ChromeOS create /etc/init/tailscaled.conf
sudo tee "/etc/init/tailscaled.conf" >/dev/null <<'EOF'
description "Tailscale node agent (Chard-provided binary)"
start on started system-services
stop on stopping system-services
respawn
respawn limit 5 10
env PORT=41641
env FLAGS=

pre-start script
  mkdir -p /run/tailscale
  chmod 0755 /run/tailscale

  # Locate .bashrc: preferred path first, then chronos' home dir
  rc=""
  for f in /home/chronos/user/.bashrc \
           "$(getent passwd chronos | cut -d: -f6)/.bashrc" \
           /home/chronos/.bashrc; do
    if [ -f "$f" ]; then rc="$f"; break; fi
  done
  [ -n "$rc" ] || { echo "tailscaled: no .bashrc found" >&2; exit 1; }

  # Marker block -> source line -> .chardrc path
  chardrc=$(sed -n '/CHARD ENV MARKER/,/END CHARD ENV MARKER/p' "$rc" \
    | grep -E '^[[:space:]]*(source|\.)[[:space:]]' \
    | head -n1 \
    | sed -E 's/^[^"]*"([^"]*)".*/\1/')
  [ -f "$chardrc" ] || { echo "tailscaled: chardrc not found ($chardrc)" >&2; exit 1; }

  # CHARD_ROOT from .chardrc (parsed, not sourced)
  root=$(sed -n 's/^CHARD_ROOT="\(.*\)"/\1/p' "$chardrc" | head -n1)
  [ -d "$root" ] || { echo "tailscaled: bad CHARD_ROOT ($root)" >&2; exit 1; }

  echo "$root" > /run/tailscale/chard_root

  mkdir -p "$root/var/lib/tailscale"
  chmod 0700 "$root/var/lib/tailscale"
  mkdir -p "$root/var/log"
end script

script
  CHARD_ROOT=$(cat /run/tailscale/chard_root)
  exec "$CHARD_ROOT/usr/sbin/tailscaled" \
    --state="$CHARD_ROOT/var/lib/tailscale/tailscaled.state" \
    --socket=/run/tailscale/tailscaled.sock \
    --port="$PORT" $FLAGS \
    >> "$CHARD_ROOT/var/log/tailscaled.log" 2>&1
end script

post-stop script
  [ -f /run/tailscale/chard_root ] || exit 0
  CHARD_ROOT=$(cat /run/tailscale/chard_root)
  "$CHARD_ROOT/usr/sbin/tailscaled" --cleanup || true
end script
EOF

sudo chmod 644 /etc/init/tailscaled.conf

# Days' cleaned it up and made it a script:

sudo nsenter -t 1 --all /bin/bash -s <<'OUTER'
cat << 'EOF' > /etc/init/tailscaled.conf
description "Tailscale node agent (Chard-provided binary)"
start on started system-services
stop on stopping system-services
respawn
respawn limit 5 10
env PORT=41641
env FLAGS=

pre-start script
  mkdir -p /run/tailscale
  chmod 0755 /run/tailscale

  # Locate .bashrc: preferred path first, then chronos' home dir
  rc=""
  for f in /home/chronos/user/.bashrc \
           "$(getent passwd chronos | cut -d: -f6)/.bashrc" \
           /home/chronos/.bashrc; do
    if [ -f "$f" ]; then rc="$f"; break; fi
  done
  [ -n "$rc" ] || { echo "tailscaled: no .bashrc found" >&2; exit 1; }

  # Marker block -> source line -> .chardrc path
  chardrc=$(sed -n '/CHARD ENV MARKER/,/END CHARD ENV MARKER/p' "$rc" \
    | grep -E '^[[:space:]]*(source|\.)[[:space:]]' \
    | head -n1 \
    | sed -E 's/^[^"]*"([^"]*)".*/\1/')
  [ -f "$chardrc" ] || { echo "tailscaled: chardrc not found ($chardrc)" >&2; exit 1; }

  # CHARD_ROOT from .chardrc (parsed, not sourced)
  root=$(sed -n 's/^CHARD_ROOT="\(.*\)"/\1/p' "$chardrc" | head -n1)
  [ -d "$root" ] || { echo "tailscaled: bad CHARD_ROOT ($root)" >&2; exit 1; }

  echo "$root" > /run/tailscale/chard_root

  mkdir -p "$root/var/lib/tailscale"
  chmod 0700 "$root/var/lib/tailscale"
  mkdir -p "$root/var/log"
end script

script
  CHARD_ROOT=$(cat /run/tailscale/chard_root)
  exec "$CHARD_ROOT/usr/sbin/tailscaled" \
    --state="$CHARD_ROOT/var/lib/tailscale/tailscaled.state" \
    --socket=/run/tailscale/tailscaled.sock \
    --port="$PORT" $FLAGS \
    >> "$CHARD_ROOT/var/log/tailscaled.log" 2>&1
end script

post-stop script
  [ -f /run/tailscale/chard_root ] || exit 0
  CHARD_ROOT=$(cat /run/tailscale/chard_root)
  "$CHARD_ROOT/usr/sbin/tailscaled" --cleanup || true
end script
EOF

initctl reload-configuration 2>/dev/null
initctl status tailscaled 2>/dev/null | grep -q running && restart tailscaled || start tailscaled

TS_PID=$(pidof -s tailscaled)
if [ -n "$TS_PID" ]; then
  nsenter -t "$TS_PID" -n ip rule add pref 5000 fwmark 0x80000/0xff0000 lookup 1002
else
  LOG="$(cat /run/tailscale/chard_root 2>/dev/null)/var/log/tailscaled.log"
  echo "tailscaled still not running after start; check 'initctl log tailscaled' or $LOG" >&2
fi
OUTER

sudo $CR/usr/bin/tailscale up
