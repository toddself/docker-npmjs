#!/bin/bash
set -e
source /build/docker-npmjs/buildconfig
set -x

$minimal_apt_get_install erlang-base-hipe erlang-crypto erlang-eunit \
	erlang-inets erlang-os-mon erlang-public-key erlang-ssl \
	erlang-syntax-tools erlang-tools erlang-xmerl erlang-dev libicu-dev \
	libmozjs185-dev erlang-asn1 make g++ libtool pkg-config git \
	automake autoconf autoconf-archive

git clone https://github.com/apache/couchdb.git /tmp/couchdb
cd /tmp/couchdb
git checkout tags/1.5.0

git apply /build/docker-npmjs/fast_binary_match.patch

./bootstrap
./configure --prefix=/opt/couchdb && make && make install

touch /opt/couchdb/var/log/couchdb/couch.log

useradd -d /opt/couchdb/lib/couchdb couchdb
chown -R couchdb:couchdb /opt/couchdb/etc/couchdb /opt/couchdb/var/lib/couchdb /opt/couchdb/var/log/couchdb /opt/couchdb/var/run/couchdb
chmod 0770 /opt/couchdb/etc/couchdb /opt/couchdb/var/lib/couchdb /opt/couchdb/var/log/couchdb /opt/couchdb/var/run/couchdb

mkdir /etc/service/couchdb
cp /build/docker-npmjs/runit/couchdb.sh /etc/service/couchdb/run
cp /build/docker-npmjs/50_enforce_couchdb_permissions.sh /etc/my_init.d/
