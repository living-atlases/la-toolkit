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

# Wait til mongo is up (with timeout)
MAX_RETRIES=20
RETRY_COUNT=0
echo "Waiting for MongoDB at $PARSED_HOST:$PARSED_PORT..."
until nc -z $PARSED_HOST $PARSED_PORT
do
    RETRY_COUNT=$((RETRY_COUNT+1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo ""
        echo "════════════════════════════════════════════════════════════════════════════════"
        echo "ERROR: Cannot connect to MongoDB after $MAX_RETRIES attempts!"
        echo "════════════════════════════════════════════════════════════════════════════════"
        echo ""
        echo "This usually happens when:"
        echo "  1. MongoDB container failed to start"
        echo "  2. You upgraded MongoDB version and existing data is incompatible"
        echo ""
        echo "Check MongoDB container status:"
        echo "  docker-compose -f docker-compose.develop.yml logs mongo"
        echo "  docker-compose -f docker-compose.develop.yml ps"
        echo ""
        echo "If you see MongoDB restarting with 'exit code 62' or similar errors,"
        echo "you likely have data from an older MongoDB version (e.g., MongoDB 4)"
        echo "that is incompatible with the current version (MongoDB 8)."
        echo ""
        echo "Solutions:"
        echo ""
        echo "  Option 1 - Start fresh (WARNING: This deletes all data!):"
        echo "    docker-compose -f docker-compose.develop.yml down"
        echo "    sudo rm -rf /data/la-toolkit/mongo/*"
        echo "    docker-compose -f docker-compose.develop.yml up"
        echo ""
        echo "  Option 2 - Migrate MongoDB data (RECOMMENDED if you have important data):"
        echo "    Follow the official MongoDB upgrade guide to migrate progressively:"
        echo "    MongoDB 4 → 5 → 6 → 7 → 8"
        echo ""
        echo "    Official documentation:"
        echo "    https://www.mongodb.com/docs/manual/release-notes/8.0-upgrade-standalone/"
        echo ""
        echo "════════════════════════════════════════════════════════════════════════════════"
        echo ""
        # Don't exit, allow the container to stay up so logs are visible
        sleep infinity
    fi
    echo "Attempt $RETRY_COUNT/$MAX_RETRIES: Trying to connect to MongoDB at $PARSED_HOST:$PARSED_PORT..."
    sleep 3
done

echo "✓ MongoDB connection successful!"
# Run migrations, but don't exit if they fail so the UI can show the status
cd /home/ubuntu/la-toolkit && npm run migrate || echo "WARNING: Migration failed. Proceeding to start app..."
# log more in cause of startup issues adding --verbose
# -w needs to increase file opened limits
cd /home/ubuntu/la-toolkit && forever app.js --prod --port 2010
