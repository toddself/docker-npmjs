#!/bin/bash
set -e
source /build/docker-npmjs/buildconfig
set -x

$minimal_apt_get_install git dnsutils

cat<<EOF > /opt/couchdb/etc/couchdb/local.ini
[couch_httpd_auth]
public_fields = appdotnet, avatar, avatarMedium, avatarLarge, date, email, fields, freenode, fullname, github, homepage, name, roles, twitter, type, _id, _rev
users_db_public = true

[httpd]
secure_rewrites = false

[couchdb]
delayed_commits = false
EOF

setuser couchdb /opt/couchdb/bin/couchdb -o /tmp/couchdb.stdout -e /tmp/couchdb.stderr -b;

cd /tmp
git clone git://github.com/terinjokes/npmjs.org
cd npmjs.org
git checkout -t origin/jsontool

npm install

curl -X PUT http://localhost:5984/registry

npm start --npmjs.org:couch=http://localhost:5984/registry
DEPLOY_VERSION=`git describe --tags` npm run load --npmjs.org:couch=http://localhost:5984/registry

# copy.sh doesn't work if couchdb doesn't have authentication
# https://github.com/npm/npmjs.org/issues/152
# echo 'yes'|npm run copy --npmjs.org:couch=http://localhost:5984/registry
rev=$(curl -k http://localhost:5984/registry/_design/scratch | ./node_modules/.bin/json _rev)
curl "http://localhost:5984/registry/_design/scratch" -k -X COPY -H destination:'_design/app'

setuser couchdb /opt/couchdb/bin/couchdb -d;
