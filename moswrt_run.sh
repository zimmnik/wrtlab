#!/bin/bash
# VERSION=220223
# shellcheck disable=SC1004
set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

export NAME="moswrt"
export LIBVIRT_DIR_POOL_PATH="${HOME}/BOOT"

export ROUTER_INET_IP="192.168.122.100"
export ROUTER_INET_MAC="52:54:00:55:90:00"
export NET_INET="network=default,mac=${ROUTER_INET_MAC}"

export HYPERVISOR_HOME_NET_IP="192.168.123.253"
export ROUTER_HOME_NET_IP="192.168.123.254"
export ROUTER_HOME_NET_NAME="${NAME}_homenet"
export NET_HOME="network=${ROUTER_HOME_NET_NAME}"

#NET_INET="type=direct,source=eno1,source_mode=bridge,mac=52:54:00:55:90:00"

source cfg/default/bash_functions

main () {
  #build_image
  #virtnet_setup
  #deploy
  test
}

main "$@"
