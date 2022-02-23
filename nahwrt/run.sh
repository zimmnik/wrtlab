#!/bin/bash
# VERSION=220130
# shellcheck disable=SC1004
set -o xtrace
set -o pipefail
set -o nounset
set -o errexit

NAME="nahwrt"
LIBVIRT_DIR_POOL_PATH="${HOME}/BOOT"
NET_INET="network=default,mac=52:54:00:55:90:02"
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

  if ! virsh net-dumpxml default | grep -q "<host mac='52:54:00:55:90:02' ip='192.168.122.252'/>"; then
    if virsh net-dumpxml default | grep -q "host mac='52:54:00:55:90:02'"; then
      virsh net-update default modify ip-dhcp-host '<host mac="52:54:00:55:90:02" ip="192.168.122.252"/>' --live --config --parent-index 0
    else
      virsh net-update default add-last ip-dhcp-host '<host mac="52:54:00:55:90:02" ip="192.168.122.252"/>' --live --config --parent-index 0
    fi
  fi

  #-------------------------------------------------
  if ! virsh net-info nahtestnet &> /dev/null; then
    virsh net-define <(cat << "EOF"
<network>
  <name>nahtestnet</name>
  <bridge stp='off'/>
  <ip address='192.168.124.253' netmask='255.255.255.0'>
  </ip>
</network>
EOF
)
  fi

  if ! virsh net-info nahtestnet | grep -q "Active:         yes"; then
    virsh net-start nahtestnet
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

  if [ ! -f "${LIBVIRT_DIR_POOL_PATH}/Fedora-Workstation-Live-x86_64-34-1.2.iso" ]; then 
    WRTLAB_PATH="$PWD"
    mkdir "$LIBVIRT_DIR_POOL_PATH" || true && cd "$LIBVIRT_DIR_POOL_PATH"
    curl -LO https://mirror.yandex.ru/fedora/linux/releases/34/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-34-1.2.iso
    curl -LO https://mirror.yandex.ru/fedora/linux/releases/34/Workstation/x86_64/iso/Fedora-Workstation-34-1.2-x86_64-CHECKSUM
    sha256sum --ignore-missing -c Fedora-Workstation-34-1.2-x86_64-CHECKSUM
    rm -v Fedora-Workstation-34-1.2-x86_64-CHECKSUM
    cd "$WRTLAB_PATH"
  fi

  virt-install -n "${NAME}_testclient" --install no_install=no \
   --vcpus 1 --ram 1024 --video none --graphics none \
   --osinfo linux2020 --disk none --location "${LIBVIRT_DIR_POOL_PATH}/Fedora-Workstation-Live-x86_64-34-1.2.iso" \
   --extra-args "console=ttyS0 root=live:CDLABEL=Fedora-WS-Live-34-1-2 rd.live.image systemd.unit=multi-user.target" \
   --network "${NET_HOME},mac=52:54:00:d9:8e:03" \
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
