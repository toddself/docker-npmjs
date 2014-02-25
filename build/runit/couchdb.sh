#!/bin/sh
exec /sbin/setuser couchdb /opt/couchdb/bin/couchdb >> /var/log/couchdb.log 2>&1
