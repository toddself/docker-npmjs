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
fi;
cat /usr/local/etc/default.ini | sed -e "s/database_dir = .*/database_dir = $VOLUME/" > /root/default.ini
cp /root/default.ini /usr/local/etc/default.ini
echo -e "[vhosts]\n$FULLHOST:5984 = /registry/_design/app/_rewrite" >> /usr/local/etc/couchdb/local.d/npmjs-vhost.ini
cat /opt/npmjs/kappa.json.default | sed -e "s/\${hostname}/$FULLHOST/" | sed -e "s/\${payload}/$PAYLOAD/" > /opt/npmjs/kappa.json
couchdb -b; kappa -c /opt/npmjs/kappa.json & tail -f /usr/local/var/log/couchdb/couch.log
