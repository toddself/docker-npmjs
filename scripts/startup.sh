#!/bin/bash
FULLHOST=$(hostname -f)

if [ -z $VOLUME ]; then
  VOLUME=/var/lib/couchdb;
fi

if [ -z $PAYLOAD ]; then
  PAYLOAD=1048576;
fi

if [ ! -f $VOLUME/.initialized ]; then
  cp -R /usr/local/var/lib/couchdb/* $VOLUME/.;
  touch $VOLUME/.initialized
fi;

echo -e "[couchdb]\ndatabase_dir = $VOLUME\nview_index_dir = $VOLUME" > /usr/local/etc/couchdb/local.d/couchdb.ini
echo -e "[log]\nfile = $VOLUME/couch.log" > /usr/local/etc/couchdb/local.d/log.ini
echo -e "[vhosts]\n$FULLHOST:5984 = /registry/_design/app/_rewrite" > /usr/local/etc/couchdb/local.d/npmjs-vhost.ini
cat /opt/npmjs/kappa.json.default | sed -e "s/\${hostname}/$FULLHOST/" | sed -e "s/\${payload}/$PAYLOAD/" > /var/lib/couchdb
couchdb -b; kappa -c /var/lib/couchdb/kappa.json & tail -f $VOLUME/couch.log
