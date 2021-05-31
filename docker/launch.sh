#!/bin/bash
set -e
su - ubuntu -c 'cd /home/ubuntu/la-toolkit && db-migrate up'
su - ubuntu -c 'cd /home/ubuntu/la-toolkit && forever app.js --prod --port 2010 --verbose'
