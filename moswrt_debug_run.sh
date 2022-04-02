#!/bin/bash
# shellcheck disable=SC1004
set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

NAME="moswrt"
LIBVIRT_DIR_POOL_PATH="/home/zorg/BOOT"

WRTLAB_WAN_IF="eth0"
WRTLAB_WAN_IP="192.168.122.100"
WRTLAB_WAN_MASK="255.255.255.0"
WRTLAB_WAN_GW="192.168.122.1"
WRTLAB_WAN_DNS="192.168.122.1"
WRTLAB_WAN_MAC="52:54:00:55:02:00"


WRTLAB_MNGT_IF="eth1"
WRTLAB_MNGT_IP="192.168.123.254"
WRTLAB_MNGT_MASK_LONG="255.255.255.0"
WRTLAB_MNGT_NAME="${NAME}_mngt"
WRTLAB_MNGT_IP_HOST="192.168.123.253"

WRTLAB_HOME_IF="eth2"
WRTLAB_HOME_IP="192.168.124.254"
WRTLAB_HOME_MASK_LONG="255.255.255.0"
WRTLAB_HOME_NAME="${NAME}_home"
WRTLAB_HOME_IP_HOST="192.168.124.253"

WRTLAB_DMZ_IF="eth3"
WRTLAB_DMZ_IP="192.168.125.254"
WRTLAB_DMZ_MASK_LONG="255.255.255.0"
WRTLAB_DMZ_NAME="${NAME}_dmz"
WRTLAB_DMZ_IP_HOST="192.168.125.253"

WRTLAB_VPN_IP="192.168.88.254"
WRTLAB_VPN_MASK_SHORT="24"
WRTLAB_VPN_NET="192.168.88.0/24"
WRTLAB_VPN_PORT="5151"
WRTLAB_VPN_PORT_HIDDEN="53"

WRTLAB_TEST_VPN_IP="192.168.88.200"
WRTLAB_TEST_VPN_MASK_SHORT="32"
WRTLAB_TEST_VPN_GW="192.168.88.254"
WRTLAB_TEST_VPN_NET="192.168.88.0/24"
WRTLAB_TEST_MAC="52:54:00:55:02:01"

WRTLAB_TEST_MNGT_IP="192.168.123.200"
WRTLAB_TEST_MNGT_MAC="52:54:00:55:02:02"

WRTLAB_TEST_HOME_IP="192.168.124.200"
WRTLAB_TEST_HOME_MAC="52:54:00:55:02:03"

WRTLAB_TEST_DMZ_IP="192.168.125.200"
WRTLAB_TEST_DMZ_MAC="52:54:00:55:02:04"

WRTLAB_VIRT_NETWORKS_ENABLED=true
WRTLAB_WAN_NETWORKS=(--network "network=default,mac=${WRTLAB_WAN_MAC}")
WRTLAB_LOCAL_NETWORKS=(--network "network=${WRTLAB_MNGT_NAME}" --network "network=${WRTLAB_HOME_NAME}" --network "network=${WRTLAB_DMZ_NAME}")
WRTLAB_TEST_NETWORKS=(--network "network=default,mac=${WRTLAB_TEST_MAC}")
#export WRTLAB_LOCAL_NETWORKS=(--network "network=default,mac=${WRTLAB_WAN_MAC}")
#export NET_INET="type=direct,source=eno1,source_mode=bridge"

WRTLAB_PROXY_ENABLED="true"
WRTLAB_PROXY_URL_LIBVIRT="http://${WRTLAB_WAN_GW}:3128"
WRTLAB_PROXY_URL_DOCKER="http://${HOSTNAME}:3128"
WRTLAB_PROXY_FEDORA_MAIN="http://ftp.halifax.rwth-aachen.de/fedora"
WRTLAB_PROXY_FEDORA_CODECS="http://codecs.fedoraproject.org/openh264"

source cfg/default/bash_functions

main () {
  build_image
  deploy
  test
}

main "$@"