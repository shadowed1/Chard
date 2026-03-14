#!/bin/bash
CYAN=$(tput setaf 6)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
BOLD=$(tput bold)
RESET=$(tput sgr0)
CHARD_ROOT=$(cat "/.install_path" 2>/dev/null)
GARCON_PORT=9876
PIDFILE=/tmp/chard_garcon.pid
PYFILE=/tmp/chard_garcon.py

if [ "$1" = "stop" ]; then
    if [ -f "$PIDFILE" ]; then
        kill $(cat "$PIDFILE") 2>/dev/null
        rm -f "$PIDFILE"
        echo "${YELLOW}chard_garcon stopped.${RESET}"
    else
        echo "${RED}chard_garcon not running.${RESET}"
    fi
    exit 0
fi

if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    echo "${YELLOW}chard_garcon already running (PID $(cat $PIDFILE))${RESET}"
    exit 0
fi

cat > "$PYFILE" << 'PYEOF'
import sys, socket, struct, threading, subprocess

CHARD_ROOT = sys.argv[1]
GARCON_PORT = int(sys.argv[2])

def handle_launch(data):
    if len(data) < 5:
        return b''
    payload = data[5:]
    desktop_file_id = ''
    i = 0
    while i < len(payload):
        tag = payload[i]; i += 1
        field = tag >> 3
        wire = tag & 0x7
        if wire == 2:
            length = payload[i]; i += 1
            value = payload[i:i+length].decode('utf-8', errors='replace')
            i += length
            if field == 1:
                desktop_file_id = value
        else:
            break
    print(f"[chard_garcon] LaunchApplication: {desktop_file_id}", flush=True)
    if desktop_file_id:
        subprocess.Popen(
            [f'{CHARD_ROOT}/bin/chard', 'app', desktop_file_id],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
    resp = b'\x08\x01'  # success: true
    return b'\x00' + struct.pack('>I', len(resp)) + resp

def handle_connection(conn, addr):
    print(f"[chard_garcon] connection from CID {addr[0]}", flush=True)
    try:
        conn.send(bytes.fromhex('000018040000000000000400400000000500400000fe03000000010000040800000000003f0001'))
        while True:
            data = conn.recv(4096)
            if not data:
                break
            print(f"[chard_garcon] received {len(data)} bytes", flush=True)
            resp = handle_launch(data)
            if resp:
                conn.send(resp)
    except Exception as e:
        print(f"[chard_garcon] error: {e}", flush=True)
    finally:
        conn.close()

s = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
s.setsockopt(socket.AF_VSOCK, socket.SO_VM_SOCKETS_BUFFER_SIZE, 65536)
s.bind((socket.VMADDR_CID_ANY, GARCON_PORT))
s.listen(10)
print(f"[chard_garcon] listening on vsock port {GARCON_PORT}", flush=True)
sys.stdout.flush()

while True:
    conn, addr = s.accept()
    t = threading.Thread(target=handle_connection, args=(conn, addr))
    t.daemon = True
    t.start()
PYEOF

echo "${CYAN}${BOLD}Starting chard_garcon vsock listener on port $GARCON_PORT...${RESET}"
python3 "$PYFILE" "$CHARD_ROOT" "$GARCON_PORT" &
PID=$!
echo $PID > "$PIDFILE"
echo "${GREEN}chard_garcon started (PID $PID)${RESET}"
