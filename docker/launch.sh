#!/bin/bash
# su - ubuntu -c 'cd /home/ubuntu/la-toolkit && pm2-runtime /home/ubuntu/la-toolkit/app.js -n la-toolkit --env NODE_ENV=production'
su - ubuntu -c 'cd /home/ubuntu/la-toolkit && sails lift --prod --port 2010 --verbose'
