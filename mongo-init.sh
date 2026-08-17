#!/bin/bash
set -e;

# https://stackoverflow.com/a/53522699
# https://stackoverflow.com/a/37811764
#
# mongosh, not the legacy 'mongo' shell: mongo:8 no longer ships it, and the
# entrypoint would fail here with 'mongo: command not found', leaving $LA_USER
# uncreated and the backend looping on authentication errors.
#
# mongosh authenticates on connect, so no admin.auth() call is needed inside.
mongosh --host 127.0.0.1 -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" \
        --authenticationDatabase admin "$MONGO_INITDB_DATABASE" <<EOF
  var user = '$LA_USER';
  var passwd = '$LA_PASS';

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
