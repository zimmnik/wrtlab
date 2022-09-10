#!/bin/bash
# shellcheck disable=SC1004
set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

NAME="vpswrt"
LIBVIRT_DIR_POOL_PATH="/home/zorg/BOOT"

WRTLAB_WAN_IF="eth0"
WRTLAB_WAN_IP="192.168.122.102"
WRTLAB_WAN_MASK="255.255.255.0"
WRTLAB_WAN_GW="192.168.122.1"
WRTLAB_WAN_DNS="192.168.122.1"
WRTLAB_WAN_MAC="52:54:00:55:01:00"
WRTLAB_WAN_NETWORKS=(--network "network=default,mac=${WRTLAB_WAN_MAC}")

WRTLAB_VPN_IP="192.168.99.254"
WRTLAB_VPN_MASK_SHORT="24"
WRTLAB_VPN_NET="192.168.99.0/24"
WRTLAB_VPN_PORT="5151"
WRTLAB_VPN_PORT_HIDDEN="53"

WRTLAB_TEST_VPN_IP="192.168.99.200"
WRTLAB_TEST_VPN_MASK_SHORT="32"
WRTLAB_TEST_VPN_GW="192.168.99.254"
WRTLAB_TEST_VPN_NET="0.0.0.0/0"
WRTLAB_TEST_VPN_EXT_MAC="52:54:00:55:01:01"
WRTLAB_TEST_VPN_EXT_NETWORKS=(--network "network=default,mac=${WRTLAB_TEST_VPN_EXT_MAC}")

WRTLAB_LOCAL_NETWORKS=(--network none)
#export NET_INET="type=direct,source=eno1,source_mode=bridge"

WRTLAB_PROXY_ENABLED="true"
WRTLAB_PROXY_URL_LIBVIRT="http://${WRTLAB_WAN_GW}:3128"
WRTLAB_PROXY_URL_DOCKER="http://${HOSTNAME}:3128"
WRTLAB_PROXY_FEDORA_MAIN="http://ftp.halifax.rwth-aachen.de/fedora"
WRTLAB_PROXY_FEDORA_CODECS="http://codecs.fedoraproject.org/openh264"

source profile/common/bash_functions

main () {
  build
  test
}

main "$@"
