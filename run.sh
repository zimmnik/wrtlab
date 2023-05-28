#!/bin/bash
# shellcheck disable=SC1004
#set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

NAME="ihorwrt"
WRTLAB_VERSION="22.03.0"
LIBVIRT_DIR_POOL_PATH=~/BOOT

WRTLAB_PROXY_ENABLED="false"

source profile/common/bash_functions

main () {
  check_system
  lint
  clean
  create_profile
  #build
  #test
  #deploy
}

main "$@"

#TODO
# REMOVE USELESS FORWARDING

