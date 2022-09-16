#!/bin/bash
set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

if [ "${IMG_PROXY_ENABLED}" = true ]; then
  sed -i -e "s/https/http/" repositories.conf
  echo "option http_proxy ${IMG_PROXY_URL}" >> repositories.conf && cat repositories.conf
fi

make -j4 image PACKAGES="$IMG_PACKAGES" FILES="/opt/${IMG_FILES}/files" BIN_DIR="/opt/${IMG_FILES}/img"
