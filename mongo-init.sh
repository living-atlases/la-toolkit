#!/bin/bash
set -e;

# https://stackoverflow.com/a/53522699
# https://stackoverflow.com/a/37811764
mongo -- "$MONGO_INITDB_DATABASE" <<EOF
  var rootUser = '$MONGO_INITDB_ROOT_USERNAME';
  var rootPassword = '$MONGO_INITDB_ROOT_PASSWORD';
  var user = '$LA_USER';
  var passwd = '$LA_PASS';

  var admin = db.getSiblingDB('admin');

  admin.auth(rootUser, rootPassword);
  db.createUser({
    user: user,
    pwd: passwd,
    roles: [
      {
        role: "root",
        db: "admin"
      }
    ]
  });
EOF
