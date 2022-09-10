#!/bin/bash
# shellcheck disable=SC1004
set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

NAME="moswrt"
WRTLAB_VERSION="22.03.0"
LIBVIRT_DIR_POOL_PATH="/home/zorg/BOOT"

WRTLAB_PROXY_ENABLED="true"

source profile/common/bash_functions

main () {
  build
  test
}

main "$@"
