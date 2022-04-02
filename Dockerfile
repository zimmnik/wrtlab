FROM	 	fedora:35
MAINTAINER	Semyon Vasilkov <github@zimmnik.ru>
LABEL		Description="Openwrt build image" Version="0.0.3"

USER		root
RUN		yum -y install vim mc less tree xz wireguard-tools && \
		yum -y --setopt install_weak_deps=False --skip-broken install \
		bash-completion bzip2 gcc gcc-c++ git make ncurses-devel patch \
		rsync tar unzip wget which diffutils python2 python3 perl-base \
		perl-Data-Dumper perl-File-Compare perl-File-Copy perl-FindBin \
		perl-Thread-Queue qemu-img && \
    		yum clean all && rm -rf /var/cache/yum && \
		cd /usr/src && \
		curl -LO https://downloads.openwrt.org/releases/21.02.2/targets/x86/64/openwrt-imagebuilder-21.02.2-x86-64.Linux-x86_64.tar.xz && \
		curl -LO https://downloads.openwrt.org/releases/21.02.2/targets/x86/64/sha256sums && \
		sha256sum --ignore-missing -c sha256sums && \
		tar -vxJf openwrt-imagebuilder-21.02.2-x86-64.Linux-x86_64.tar.xz && \
		ln -s openwrt-imagebuilder-21.02.2-x86-64.Linux-x86_64 builder

WORKDIR		/usr/src/builder

#docker build -t fedora:35-wrtlab .
