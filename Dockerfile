# Version: 0.6.0-head
FROM phusion/baseimage:0.9.6
MAINTAINER Terin Stock <terinjokes@gmail.com>

ENV PATH /opt/node/bin/:$PATH
ENV HOME /root

VOLUME ["/opt/couchdb/var/lib/couchdb/"]

CMD ["/sbin/my_init"]

ADD build /build/docker-npmjs
RUN /build/docker-npmjs/prepare.sh && \
	/build/docker-npmjs/install_couchdb.sh

RUN /build/docker-npmjs/install_node.sh
RUN /build/docker-npmjs/install_npmjs.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
