FROM	 	fedora:36
MAINTAINER	Semyon Vasilkov <github@zimmnik.ru>
LABEL		Description="Openwrt build image" Version="0.0.4"

USER		root

COPY		dockerfile_bootstrap.sh /tmp/
RUN		/tmp/dockerfile_bootstrap.sh

WORKDIR		/usr/src/builder
