#!/bin/bash
# VERSION=220223
# shellcheck disable=SC1004
set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

source wrtlab_functions

export NAME="moswrt"
export LIBVIRT_DIR_POOL_PATH="${HOME}/BOOT"
export NET_INET="network=default,mac=52:54:00:55:90:01"
export NET_HOME="network=nahtestnet"

#NET_INET="type=direct,source=eno1,source_mode=bridge,mac=52:54:00:55:90:00"

main () {
  build_image
  virtnet_setup
  deploy
  test
}

main "$@"
