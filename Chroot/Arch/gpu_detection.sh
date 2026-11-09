for i in /sys/class/drm/card*/device/driver; do
    printf '%s -> ' "$i"
    readlink -f "$i"
done
