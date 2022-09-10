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
WRTLAB_PROXY_URL_LIBVIRT="http://${WRTLAB_WAN_GW}:3128"
WRTLAB_PROXY_URL_DOCKER="http://${HOSTNAME}:3128"
WRTLAB_PROXY_FEDORA_MAIN="http://fedora.mirrorservice.org/fedora"
WRTLAB_PROXY_FEDORA_CODECS="http://codecs.fedoraproject.org/openh264"

source profile/common/bash_functions

main () {
  build
  test
}

main "$@"
