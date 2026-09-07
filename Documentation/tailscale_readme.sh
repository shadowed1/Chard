# Install Tailscale in Chard normally.
# In ChromeOS create /etc/init/tailscaled.conf

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
  mkdir -p /usr/local/chard/var/lib/tailscale
  chmod 0700 /usr/local/chard/var/lib/tailscale
  mkdir -p /usr/local/chard/var/log
end script

exec /usr/local/chard/usr/sbin/tailscaled \
  --state=/usr/local/chard/var/lib/tailscale/tailscaled.state \
  --socket=/run/tailscale/tailscaled.sock \
  --port=$PORT $FLAGS \
  >> /usr/local/chard/var/log/tailscaled.log 2>&1

post-stop exec /usr/local/chard/usr/sbin/tailscaled --cleanup

# In ChromeOS Shell:

sudo nsenter -t "$(pidof tailscaled)" -n \
    ip rule add pref 5000 \
    fwmark 0x80000/0xff0000 \
    lookup 1002

sudo $CR/usr/bin/tailscale up
