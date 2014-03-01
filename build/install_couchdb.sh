#!/bin/bash
set -e
source /build/docker-npmjs/buildconfig
set -x

$minimal_apt_get_install erlang-base-hipe erlang-crypto erlang-eunit \
	erlang-inets erlang-os-mon erlang-public-key erlang-ssl \
	erlang-syntax-tools erlang-tools erlang-xmerl erlang-dev libicu-dev \
	libmozjs185-dev make g++ erlang-asn1

cd /tmp
curl -L# http://www.carfab.com/apachesoftware/couchdb/source/1.5.0/apache-couchdb-1.5.0.tar.gz|tar -zx
cd /tmp/apache-couchdb-1.5.0

./configure --prefix=/opt/couchdb && make && make install

touch /opt/couchdb/var/log/couchdb/couch.log

useradd -d /opt/couchdb/lib/couchdb couchdb
chown -R couchdb:couchdb /opt/couchdb/etc/couchdb /opt/couchdb/var/lib/couchdb /opt/couchdb/var/log/couchdb /opt/couchdb/var/run/couchdb
chmod 0770 /opt/couchdb/etc/couchdb /opt/couchdb/var/lib/couchdb /opt/couchdb/var/log/couchdb /opt/couchdb/var/run/couchdb

mkdir /etc/service/couchdb
cp /build/docker-npmjs/runit/couchdb.sh /etc/service/couchdb/run
cp /build/docker-npmjs/50_enforce_couchdb_permissions.sh /etc/my_init.d/
