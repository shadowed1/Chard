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

mkdir -p /tmp/vm_applications /tmp/arc

fetch "system_api/dbus/vm_applications/apps.proto"   /tmp/vm_applications/apps.proto
fetch "system_api/dbus/vm_cicerone/cicerone_service.proto" /tmp/cicerone_service.proto
fetch "system_api/dbus/vm_concierge/concierge_service.proto" /tmp/concierge_service.proto
fetch "system_api/dbus/arc/arc.proto"                /tmp/arc/arc.proto
fetch "vm_tools/proto/common.proto"                  /tmp/common.proto
fetch "vm_tools/proto/container_host.proto"          /tmp/container_host.proto
fetch "vm_tools/proto/container_guest.proto"         /tmp/container_guest.proto

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

echo "${GREEN}Proto setup complete. ${RESET}"
echo
