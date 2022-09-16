#!/bin/bash

set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

WRTLAB_PROXY_ENABLED="__WRTLAB_PROXY_ENABLED__"

if [ "${WRTLAB_PROXY_ENABLED}" = true ]; then
  # REPO SETUP
  # shellcheck disable=SC2016
  sed -i '/fedora-cisco-openh264-$releasever/i \#baseurl=__WRTLAB_PROXY_FEDORA_CODECS__/$releasever/$basearch/os/' /etc/yum.repos.d/fedora-cisco-openh264.repo
    
  while read -r filename; do
    sed -i 's%http://download.example/pub/fedora/%__WRTLAB_PROXY_FEDORA_MAIN__/%g' "$filename"
    sed -i 's/#baseurl/baseurl/g' "$filename"
  done < <(grep -ril 'baseurl' /etc/yum.repos.d/)
    
  while read -r filename; do 
    sed -i 's/metalink/#metalink/g' "$filename"
  done < <(grep -ril 'metalink' /etc/yum.repos.d/)
  
  echo -e 'deltarpm=false\nzchunk=false'| tee -a /etc/dnf/dnf.conf

  cat /etc/yum.repos.d/*

  export http_proxy=__WRTLAB_PROXY_URL_DOCKER__
fi

yum -y install vim mc less tree xz wireguard-tools
yum -y --setopt install_weak_deps=False --skip-broken install bash-completion bzip2 gcc gcc-c++ git make ncurses-devel patch rsync tar unzip wget which diffutils python2 python3 perl-base perl-Data-Dumper perl-File-Compare perl-File-Copy perl-FindBin perl-Thread-Queue qemu-img
yum clean all && rm -rf /var/cache/yum

cd /usr/src

curl -LO http://downloads.openwrt.org/releases/__WRTLAB_VERSION__/targets/x86/64/openwrt-imagebuilder-__WRTLAB_VERSION__-x86-64.Linux-x86_64.tar.xz
curl -LO http://downloads.openwrt.org/releases/__WRTLAB_VERSION__/targets/x86/64/sha256sums
sha256sum --ignore-missing -c sha256sums

tar -vxJf openwrt-imagebuilder-__WRTLAB_VERSION__-x86-64.Linux-x86_64.tar.xz
ln -s openwrt-imagebuilder-__WRTLAB_VERSION__-x86-64.Linux-x86_64 builder

mv /tmp/run.sh builder/
