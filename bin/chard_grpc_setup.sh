#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

BASE="https://chromium.googlesource.com/chromiumos/platform2/+/refs/heads/main"
fetch() { curl -s "$BASE/$1?format=TEXT" | base64 -d > "$2"; }

sudo rm -f /tmp/vm_applications/apps_pb2.py /tmp/arc/arc_pb2.py \
           /tmp/common_pb2.py /tmp/container_host_pb2.py \
           /tmp/container_guest_pb2.py /tmp/cicerone_service_pb2.py \
           /tmp/concierge_service_pb2.py 2>/dev/null
           
echo "${CYAN}${BOLD}Fetching protos...${RESET}"
echo
mkdir -p /tmp/vm_applications /tmp/arc
fetch "system_api/dbus/vm_applications/apps.proto"           /tmp/vm_applications/apps.proto
fetch "system_api/dbus/vm_cicerone/cicerone_service.proto"   /tmp/cicerone_service.proto
fetch "system_api/dbus/vm_concierge/concierge_service.proto" /tmp/concierge_service.proto
fetch "system_api/dbus/arc/arc.proto"                        /tmp/arc/arc.proto
fetch "vm_tools/proto/common.proto"                          /tmp/common.proto
fetch "vm_tools/proto/container_host.proto"                  /tmp/container_host.proto
fetch "vm_tools/proto/container_guest.proto"                 /tmp/container_guest.proto

echo "${CYAN}${BOLD}Compiling protos...${RESET}"
echo
protoc --proto_path=/tmp --python_out=/tmp /tmp/vm_applications/apps.proto
protoc --proto_path=/tmp --python_out=/tmp /tmp/arc/arc.proto
protoc --proto_path=/tmp --python_out=/tmp /tmp/common.proto
protoc --proto_path=/tmp --python_out=/tmp /tmp/container_host.proto
protoc --proto_path=/tmp --python_out=/tmp /tmp/container_guest.proto
protoc --proto_path=/tmp --python_out=/tmp /tmp/cicerone_service.proto
protoc --proto_path=/tmp --python_out=/tmp /tmp/concierge_service.proto

cat > /tmp/container_listener_stub.py << 'STUB'
import grpc, sys
sys.path.insert(0, '/tmp')
import container_host_pb2, common_pb2
class ContainerListenerStub:
    def __init__(self, channel):
        self.ContainerReady = channel.unary_unary(
            '/vm_tools.container.ContainerListener/ContainerReady',
            request_serializer=container_host_pb2.ContainerStartupInfo.SerializeToString,
            response_deserializer=common_pb2.EmptyMessage.FromString,
        )
STUB

echo "${GREEN}Proto setup complete.${RESET}"
echo
echo "${CYAN}${BOLD}Fetching container tokens...${RESET}"
echo

python3 - << 'PYEOF'
import sys
sys.path.insert(0, '/tmp')
import vm_applications.apps_pb2
import arc.arc_pb2
import concierge_service_pb2
import cicerone_service_pb2
import dbus

U_HASH = open('/.chard_hash').read().strip()
req = cicerone_service_pb2.ListRunningContainersRequest()
req.owner_id = U_HASH
bus = dbus.SystemBus()
svc = bus.get_object('org.chromium.VmCicerone', '/org/chromium/VmCicerone')
iface = dbus.Interface(svc, 'org.chromium.VmCicerone')
result = iface.ListRunningContainers(dbus.Array(req.SerializeToString(), signature='y'))
resp = cicerone_service_pb2.ListRunningContainersResponse()
resp.ParseFromString(bytes(result))

lines = []
for c in resp.containers:
    line = f"{c.vm_name}:{c.container_name}:{c.container_token}"
    lines.append(line)
    print(f"  {c.vm_name}/{c.container_name} -> {c.container_token}")

with open('/.chard_tokens', 'w') as f:
    f.write('\n'.join(lines) + '\n')

print(f"\n{len(lines)} container(s) written to /.chard_tokens")
PYEOF
