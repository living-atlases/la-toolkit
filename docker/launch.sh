#!/bin/bash
set -e

# Load the profile (to get the npm vars, etcetera)
. /home/ubuntu/.profile

echo Using database connection url for migrations: $DATABASE_URL

# https://stackoverflow.com/a/40681059
PARSED_PROTO="$(echo $DATABASE_URL | sed -nr 's,^(.*://).*,\1,p')"
# Remove the protocol from the URL.
PARSED_URL="$(echo ${DATABASE_URL/$PARSED_PROTO/})"
# Extract the user (includes trailing "@").
PARSED_USER="$(echo $PARSED_URL | sed -nr 's,^(.*@).*,\1,p')"
# Remove the user from the URL.
PARSED_URL="$(echo ${PARSED_URL/$PARSED_USER/})"
# Extract the port (includes leading ":").
PARSED_PORT="$(echo $PARSED_URL | sed -nr 's,.*(:[0-9]+).*,\1,p')"
# Remove the port from the URL.
PARSED_URL="$(echo ${PARSED_URL/$PARSED_PORT/})"
# Extract the path (includes leading "/" or ":").
PARSED_PATH="$(echo $PARSED_URL | sed -nr 's,[^/:]*([/:].*),\1,p')"
# Remove the path from the URL.
PARSED_HOST="$(echo ${PARSED_URL/$PARSED_PATH/})"
# Remove the ":" from the PORT
PARSED_PORT="$(echo $PARSED_PORT | cut -d ":" -f 2)"

# Fix container perms on launch (issue #3)
for DIR in /home/ubuntu/ansible/la-inventories /home/ubuntu/ansible/logs /home/ubuntu/.ssh /home/ubuntu/ansible/ala-install
do
    DIR_USER=$(stat -c '%U' $DIR)
    DIR_GROUP=$(stat -c '%G' $DIR)
    if [[ "$DIR_USER" != 'ubuntu' || "$DIR_GROUP" != "ubuntu" ]]
    then
        echo Fixing owner of $DIR
        sudo chown ubuntu:ubuntu $DIR
    fi
done

# Wait til mongo is up
until nc -z $PARSED_HOST $PARSED_PORT
do
    echo Trying to connect to the mongo db at $PARSED_HOST:$PARSED_PORT...
    sleep 3
done
# Run migrations, but don't exit if they fail so the UI can show the status
cd /home/ubuntu/la-toolkit && npm run migrate || echo "WARNING: Migration failed. Proceeding to start app..."
# log more in cause of startup issues adding --verbose
# -w needs to increase file opened limits
cd /home/ubuntu/la-toolkit && forever app.js --prod --port 2010
