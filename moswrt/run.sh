#!/bin/bash
# VERSION=220130
# shellcheck disable=SC1004
set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

NAME="moswrt"
LIBVIRT_DIR_POOL_PATH="${HOME}/BOOT"
NET_INET="network=default,mac=52:54:00:55:90:01"
NET_HOME="network=nahtestnet"

#NET_INET="type=direct,source=eno1,source_mode=bridge,mac=52:54:00:55:90:00"

build_image () {
  #-------------------------------------------------
  FLD=files/etc/dropbear
  mkdir -p ${FLD}
  cp -v  ~/.ssh/authorized_keys ${FLD}/
  chmod og-rwx ${FLD}/authorized_keys

  #-------------------------------------------------
  if ! docker inspect --type=image fedora:35-wrtlab > /dev/null; then docker build -t fedora:35-wrtlab .; fi

  rm -rfv img/*

  docker run -it -v "${PWD}:/opt:Z" --rm fedora:35-wrtlab bash -x -c '\
  PACKAGES="cgi-io libiwinfo libiwinfo-data libiwinfo-lua liblua liblucihttp liblucihttp-lua libubus-lua lua luci luci-app-firewall luci-app-opkg luci-base luci-lib-base luci-lib-ip luci-lib-jsonc luci-lib-nixio luci-mod-admin-full luci-mod-network luci-mod-status luci-mod-system luci-proto-ppp luci-ssl px5g-wolfssl rpcd rpcd-mod-file rpcd-mod-iwinfo rpcd-mod-luci rpcd-mod-rrdns uhttpd uhttpd-mod-ubus luci-app-wireguard arp-scan arp-scan-database grub2 grub2-efi kmod-fs-vfat kmod-nls-base kmod-nls-cp437 kmod-nls-iso8859-1 kmod-nls-utf8 iperf3 openssh-client-utils"; \
  make -j4 image FILES="/opt/files" BIN_DIR="/opt/img" PACKAGES="$PACKAGES" && \
  cd /opt/img/ && gzip -d openwrt-21.02.1-x86-64-generic-ext4-combined.img.gz; \
  qemu-img convert -f raw -O qcow2 openwrt-21.02.1-x86-64-generic-ext4-combined.img '$NAME'.qcow2'
  #guestmount -a tmp/rr1router.qcow2 -i --rw mnt/
}

virtnet_setup () {
  #-------------------------------------------------
  if ! virsh net-info default | grep -q "Active:         yes"; then
    virsh net-start default
  fi

  if ! virsh net-dumpxml default | grep -q "<host mac='52:54:00:55:90:01' ip='192.168.122.251'/>"; then
    if virsh net-dumpxml default | grep -q "host mac='52:54:00:55:90:01'"; then
      virsh net-update default modify ip-dhcp-host '<host mac="52:54:00:55:90:01" ip="192.168.122.251"/>' --live --config --parent-index 0
    else
      virsh net-update default add-last ip-dhcp-host '<host mac="52:54:00:55:90:01" ip="192.168.122.251"/>' --live --config --parent-index 0
    fi
  fi

  #-------------------------------------------------
  if ! virsh net-info mostestnet &> /dev/null; then
    virsh net-define <(cat << "EOF"
<network>
  <name>mostestnet</name>
  <bridge stp='off'/>
  <ip address='192.168.123.253' netmask='255.255.255.0'>
  </ip>
</network>
EOF
)
  fi

  if ! virsh net-info mostestnet | grep -q "Active:         yes"; then
    virsh net-start mostestnet
  fi
}


deploy () {
  if virsh dominfo "${NAME}_testclient" &> /dev/null; then
    if virsh dominfo "${NAME}_testclient" | grep -q "State:          running"; then
      virsh destroy "${NAME}_testclient"
    fi
    virsh undefine "${NAME}_testclient"
  fi

  if virsh dominfo "${NAME}" &> /dev/null; then
    if virsh dominfo "${NAME}" | grep -q "State:          running"; then
      virsh destroy "${NAME}"
    fi
    virsh undefine "${NAME}" --remove-all-storage
  fi

  if [ ! -d "$LIBVIRT_DIR_POOL_PATH" ]; then
    mkdir "$LIBVIRT_DIR_POOL_PATH" || true
    chown "${USER}:qemu" "$LIBVIRT_DIR_POOL_PATH"
    chmod g+rws "$LIBVIRT_DIR_POOL_PATH"
  fi
  cp -v "img/${NAME}.qcow2" "$LIBVIRT_DIR_POOL_PATH"
  
  #osinfo-query os
  virt-install -n "${NAME}" --install no_install=yes \
   --vcpus 1 --ram 128 --video none --graphics none  \
   --osinfo linux2020 --disk path="${LIBVIRT_DIR_POOL_PATH}/${NAME}.qcow2" \
   --network "${NET_HOME}" \
   --network "${NET_INET}" \
   --noautoconsole
}

test () {
  scripts/router_internal_test.exp ${NAME}

  if [ ! -f "${LIBVIRT_DIR_POOL_PATH}/alpine-virt-3.15.0-x86_64.iso" ]; then 
    WRTLAB_PATH="$PWD"
    mkdir "$LIBVIRT_DIR_POOL_PATH" || true && cd "$LIBVIRT_DIR_POOL_PATH"
    curl -LO https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-virt-3.15.0-x86_64.iso
    curl -LO https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-virt-3.15.0-x86_64.iso.sha256
    sha256sum --ignore-missing -c alpine-virt-3.15.0-x86_64.iso.sha256
    rm -v alpine-virt-3.15.0-x86_64.iso.sha256
    cd "$WRTLAB_PATH"
  fi

  virt-install -n "${NAME}_testclient" --install no_install=yes \
   --vcpus 1 --ram 256 --video none --graphics none \
   --osinfo alpinelinux3.14 --disk device=cdrom,path="${LIBVIRT_DIR_POOL_PATH}/alpine-virt-3.15.0-x86_64.iso" \
   --network "${NET_HOME},mac=52:54:00:d9:8e:04" \
   --noautoconsole
  
  scripts/router_external_test.exp "${NAME}_testclient"
}

main () {
  build_image
  virtnet_setup
  deploy
  test
}

main "$@"