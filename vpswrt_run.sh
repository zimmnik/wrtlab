#!/bin/bash
# VERSION=220223
# shellcheck disable=SC1004
set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

export NAME="vpswrt"
export LIBVIRT_DIR_POOL_PATH="/data/libvirt-boot"

export NET_INET="type=direct,source=eno2.2,source_mode=bridge,mac=52:54:00:55:90:03"
export NET_HOME="none"
#export NET_INET="network=default,mac=${ROUTER_INET_MAC}"

export WRTLAB_WAN_IP="10.64.0.1"
export WRTLAB_WAN_MASK="255.255.255.0"
export WRTLAB_WAN_GW="10.64.0.254"
export WRTLAB_WAN_DNS="10.64.0.254"

export WRTLAB_VPN_IP="192.168.88.254/24"

source cfg/default/bash_functions

main () {
  build_image
  deploy
  test
}

main "$@"
