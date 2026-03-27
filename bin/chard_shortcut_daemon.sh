#!/bin/bash
# chard_shortcut_daemon
# chard_shortcut_daemon start - start daemon
# chard_shortcut_daemon stop - stop daemon
# chard_shortcut_daemon status - check if daemon is running
# chard_shortcut_daemon sync - one-shot sync then exit
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
DEFAULT_CHARD_ROOT="/usr/local/chard"
LOG_FILE="/tmp/chard_shortcut_daemon.log"
PID_FILE="/tmp/chard_shortcut_daemon.pid"
STATE_FILE="/tmp/chard_shortcut_daemon.state"
POLL_INTERVAL=20
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

die() {
    log "FATAL: $*"
    exit 1
}
resolve_paths() {
    if [ -n "$CHARD_ROOT" ] && [ -f "$CHARD_ROOT/.install_path" ]; then
        CHARD_ROOT=$(sudo cat "$CHARD_ROOT/.install_path")
    elif [ -f "$DEFAULT_CHARD_ROOT/.install_path" ]; then
        CHARD_ROOT=$(sudo cat "$DEFAULT_CHARD_ROOT/.install_path")
    else
        CHARD_ROOT="$DEFAULT_CHARD_ROOT"
    fi
    U_HASH=$(sudo ls /home/.shadow/ 2>/dev/null | grep -v 'salt\|root' | head -1)
    [ -z "$U_HASH" ] && die "Could not resolve user hash from /home/.shadow/"
    CHARD_HOME=$(cat "$CHARD_ROOT/.chard_home" 2>/dev/null || echo "/home/chronos")
    CHARD_APPS="$CHARD_ROOT/usr/share/applications"
    ICONS_HICOLOR="$CHARD_ROOT/usr/share/icons/hicolor"
    ICONS_PIXMAPS="$CHARD_ROOT/usr/share/pixmaps"
    SHARED="/home/chronos/user/MyFiles/Downloads/chard_icons"
    ICON_SERVICE_BASE="/home/user/$U_HASH/app_service/icons"
    mkdir -p "$SHARED/desktops" "$SHARED/launch" "$SHARED/icons"
}
generate_app_id() {
    echo -n "crostini:termina/penguin/chard-$1" | \
        sha256sum | head -c 32 | tr '[:lower:]' '[:upper:]' | \
        tr '0123456789ABCDEF' 'abcdefghijklmnop'
}
find_png() {
    local icon_name="$1"
    for size in 128 96 64 48 32 16; do
        local p="$ICONS_HICOLOR/${size}x${size}/apps/${icon_name}.png"
        [ -f "$p" ] && echo "$p" && return
    done
    local p="$ICONS_PIXMAPS/${icon_name}.png"
    [ -f "$p" ] && echo "$p" && return
    find "$ICONS_HICOLOR" -name "${icon_name}.png" 2>/dev/null | head -1
}
install_icons() {
    local icon_name="$1"
    local app_id="$2"
    local icon_dir="$ICON_SERVICE_BASE/$app_id"
    local shared_icon_dir="$SHARED/icons/$app_id"
    sudo mkdir -p "$icon_dir"
    sudo chmod 755 "$icon_dir"
    mkdir -p "$shared_icon_dir"
    local count=0
    for size in 16 32 48 64 96 128; do
        local src="$ICONS_HICOLOR/${size}x${size}/apps/${icon_name}.png"
        if [ -f "$src" ]; then
            sudo cp "$src" "$icon_dir/${size}.png"
            sudo chmod 644 "$icon_dir/${size}.png"
            cp "$src" "$shared_icon_dir/${size}.png"
            count=$((count + 1))
        fi
    done
    if [ "$count" -eq 0 ]; then
        local fallback
        fallback=$(find_png "$icon_name")
        if [ -n "$fallback" ]; then
            for size in 16 32 48 64 96 128; do
                sudo cp "$fallback" "$icon_dir/${size}.png"
                sudo chmod 644 "$icon_dir/${size}.png"
                cp "$fallback" "$shared_icon_dir/${size}.png"
            done
            count=6
        fi
    fi
    echo "$icon_name" > "$shared_icon_dir/.icon_name"
    echo "$count"
}
remove_shortcut() {
    local desktop_file_id="$1"
    local app_id
    app_id=$(generate_app_id "$desktop_file_id")
    local icon_dir="$ICON_SERVICE_BASE/$app_id"
    local shared_icon_dir="$SHARED/icons/$app_id"
    local desktop_stub="$SHARED/desktops/chard-${desktop_file_id}.desktop"
    sudo rm -rf "$icon_dir"
    rm -rf "$shared_icon_dir"
    rm -f "$desktop_stub"
    log "Removed: $desktop_file_id ($app_id)"
}
write_desktop_stub() {
    local desktop_file_id="$1"
    local name="$2"
    local icon="$3"
    local wm_class="$4"
    cat > "$SHARED/desktops/chard-${desktop_file_id}.desktop" << DESKTOP
[Desktop Entry]
Type=Application
Name=$name
Exec=/usr/local/bin/chard_bridge $desktop_file_id
Icon=$icon
Terminal=false
NoDisplay=false
StartupWMClass=$wm_class
DESKTOP
}
desktop_fingerprint() {
    local df="$1"
    grep -E '^(Name|Icon|StartupWMClass|NoDisplay|OnlyShowIn|Type)=' "$df" | sha256sum | cut -d' ' -f1
}
state_get() {
    local id="$1"
    grep "^$id " "$STATE_FILE" 2>/dev/null | awk '{print $2}'
}
state_set() {
    local id="$1" fp="$2"
    sed -i "/^$id /d" "$STATE_FILE" 2>/dev/null
    echo "$id $fp" >> "$STATE_FILE"
}
state_remove() {
    local id="$1"
    sed -i "/^$id /d" "$STATE_FILE" 2>/dev/null
}
state_all_ids() {
    awk '{print $1}' "$STATE_FILE" 2>/dev/null
}
should_register() {
    local df="$1"
    local type no_display only_show
    type=$(grep -m1 '^Type=' "$df" | cut -d= -f2 | tr -d '[:space:]')
    no_display=$(grep -m1 '^NoDisplay=' "$df" | cut -d= -f2 | tr -d '[:space:]')
    only_show=$(grep -m1 '^OnlyShowIn=' "$df" | cut -d= -f2)
    [ "$type" != "Application" ] && return 1
    [ "$no_display" = "true" ] && return 1
    echo "$only_show" | grep -q "XFCE" && return 1
    return 0
}
current_ids() {
    for df in "$CHARD_APPS"/*.desktop; do
        [ -f "$df" ] || continue
        should_register "$df" || continue
        basename "$df" .desktop
    done
}
do_sync() {
    [ -f "$STATE_FILE" ] || touch "$STATE_FILE"
    local added=0 removed=0 updated=0
    for df in "$CHARD_APPS"/*.desktop; do
        [ -f "$df" ] || continue
        should_register "$df" || continue
        local id fp_new fp_old
        id=$(basename "$df" .desktop)
        fp_new=$(desktop_fingerprint "$df")
        fp_old=$(state_get "$id")
        if [ -z "$fp_old" ]; then
            local name icon wm_class app_id icons_count
            name=$(grep -m1 '^Name=' "$df" | cut -d= -f2-)
            icon=$(grep -m1 '^Icon=' "$df" | cut -d= -f2 | tr -d '[:space:]')
            wm_class=$(grep -m1 '^StartupWMClass=' "$df" | cut -d= -f2 | tr -d '[:space:]')
            [ -z "$wm_class" ] && wm_class="$id"
            app_id=$(generate_app_id "$id")
            icons_count=$(install_icons "$icon" "$app_id")
            write_desktop_stub "$id" "$name" "$icon" "$wm_class"
            state_set "$id" "$fp_new"
            log "Added: $id ($app_id, $icons_count icons)"
            added=$((added + 1))
        elif [ "$fp_new" != "$fp_old" ]; then
            local name icon wm_class app_id icons_count
            name=$(grep -m1 '^Name=' "$df" | cut -d= -f2-)
            icon=$(grep -m1 '^Icon=' "$df" | cut -d= -f2 | tr -d '[:space:]')
            wm_class=$(grep -m1 '^StartupWMClass=' "$df" | cut -d= -f2 | tr -d '[:space:]')
            [ -z "$wm_class" ] && wm_class="$id"
            app_id=$(generate_app_id "$id")
            icons_count=$(install_icons "$icon" "$app_id")
            write_desktop_stub "$id" "$name" "$icon" "$wm_class"
            state_set "$id" "$fp_new"
            log "Updated: $id ($app_id)"
            updated=$((updated + 1))
        fi
    done
    local current_list
    current_list=$(current_ids)
    while IFS= read -r installed_id; do
        [ -z "$installed_id" ] && continue
        if ! echo "$current_list" | grep -qx "$installed_id"; then
            remove_shortcut "$installed_id"
            state_remove "$installed_id"
            removed=$((removed + 1))
        fi
    done < <(state_all_ids)
    if [ $((added + updated + removed)) -gt 0 ]; then
        touch "$SHARED/.sync_now"
        sudo chown -R 1000:1000 "$SHARED/" 2>/dev/null
        log "Sync complete — added=$added updated=$updated removed=$removed"
    fi
}
apps_dir_checksum() {
    find "$CHARD_APPS" -maxdepth 1 -name '*.desktop' -printf '%f %T@\n' 2>/dev/null \
        | sort | sha256sum | cut -d' ' -f1
}
pid_write() {
    echo $$ > "$PID_FILE"
}
pid_read() {
    cat "$PID_FILE" 2>/dev/null
}
pid_running() {
    local pid
    pid=$(pid_read)
    [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}
pid_clear() {
    rm -f "$PID_FILE"
}
on_exit() {
    log "Daemon stopping (PID $$)"
    pid_clear
}
on_term() {
    log "Received SIGTERM — shutting down"
    exit 0
}
run_daemon() {
    resolve_paths
    trap on_exit EXIT
    trap on_term TERM INT
    pid_write
    log "Daemon started (PID $$, CHARD_ROOT=$CHARD_ROOT, poll=${POLL_INTERVAL}s)"
    do_sync
    local last_checksum=""
    while true; do
        sleep "$POLL_INTERVAL"
        local current_checksum
        current_checksum=$(apps_dir_checksum)

        if [ "$current_checksum" != "$last_checksum" ]; then
            last_checksum="$current_checksum"
            do_sync
        fi
    done
}
sync_aliases() {
    local bashrc="$CHARD_ROOT/$CHARD_HOME/.bashrc"
    local aliases_file="$SHARED/.chard_aliases"
    > "$aliases_file"
    if [ -f "$bashrc" ]; then
        grep -E "^alias " "$bashrc" | while read -r line; do
            local aname aval
            aname=$(echo "$line" | sed "s/alias \([^=]*\)=.*/\1/")
            aval=$(echo "$line" | sed "s/alias [^=]*=['\"]//;s/['\"]$//")
            echo "$aname=$aval" >> "$aliases_file"
        done
        log "Aliases synced ($(wc -l < "$aliases_file") entries)"
    fi
}
CMD="${1:-start}"
case "$CMD" in
    start)
        if pid_running; then
            echo "chard_shortcut_daemon already running (PID $(pid_read))" >&2
            exit 0
        fi
        nohup "$0" _run >> "$LOG_FILE" 2>&1 &
        echo "chard_shortcut_daemon started (PID $!)"
        ;;

    stop)
        if pid_running; then
            local pid
            pid=$(pid_read)
            kill "$pid" 2>/dev/null
            local i=0
            while pid_running && [ $i -lt 10 ]; do
                sleep 0.5
                i=$((i + 1))
            done
            pid_running && kill -9 "$pid" 2>/dev/null
            pid_clear
            echo "chard_shortcut_daemon stopped"
        else
            echo "chard_shortcut_daemon not running"
        fi
        ;;

    status)
        if pid_running; then
            echo "chard_shortcut_daemon running (PID $(pid_read))"
        else
            echo "chard_shortcut_daemon not running"
        fi
        ;;

    sync)
        resolve_paths
        sync_aliases
        do_sync
        echo "One-shot sync complete. See $LOG_FILE for details."
        ;;

    _run)
        resolve_paths
        sync_aliases
        run_daemon
        ;;

    *)
        echo "Usage: $0 {start|stop|status|sync}" >&2
        if pid_running; then
            echo "chard_shortcut_daemon running (PID $(pid_read))"
        else
            echo "chard_shortcut_daemon not running"
        fi
        ;;
esac
