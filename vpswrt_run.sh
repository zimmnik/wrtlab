#!/bin/bash
# VERSION=220223
# shellcheck disable=SC1004
set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

export NAME="vpswrt"
export LIBVIRT_DIR_POOL_PATH="/home/zorg/BOOT"

export WRTLAB_WAN_IP="192.168.122.102"
export WRTLAB_WAN_MASK="255.255.255.0"
export WRTLAB_WAN_GW="192.168.122.1"
export WRTLAB_WAN_DNS="192.168.122.1"
export WRTLAB_WAN_MAC="52:54:00:55:90:03"
export WRTLAB_WAN_NETWORKS=(--network "network=default,mac=${WRTLAB_WAN_MAC}")

export WRTLAB_VPN_IP="192.168.99.254/24"
export WRTLAB_VPN_NET="192.168.99.0/24"
export WRTLAB_VPN_PORT="5151"
export WRTLAB_VPN_PORT_HIDDEN="53"

export WRTLAB_TEST_VPN_IP="192.168.99.253/32"
export WRTLAB_TEST_VPN_GW="192.168.99.254"
export WRTLAB_TEST_MAC="52:54:00:55:90:04"
export WRTLAB_TEST_NETWORKS=(--network "network=default,mac=${WRTLAB_TEST_MAC}")

export WRTLAB_HOME_NETWORKS=(--network none)
#export NET_INET="type=direct,source=eno1,source_mode=bridge"

export WRTLAB_PROXY_ENABLED="true"
export WRTLAB_PROXY_URL_LIBVIRT="http://${WRTLAB_WAN_GW}:3128"
export WRTLAB_PROXY_URL_DOCKER="http://${HOSTNAME}:3128"
export WRTLAB_PROXY_FEDORA_MAIN="http://ftp.halifax.rwth-aachen.de/fedora"
export WRTLAB_PROXY_FEDORA_CODECS="http://codecs.fedoraproject.org/openh264"

source cfg/default/bash_functions

main () {
  build_image
  deploy
  test
}

main "$@"
