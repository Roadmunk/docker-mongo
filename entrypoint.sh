#! /bin/bash
E_UNAVAILABLE=69
set -e

if [ -n "$LOCAL_DEVICE" ]; then
	mount $LOCAL_DEVICE /data/db
fi

chown -R mongodb /data/configdb /data/db

gosu mongodb mongod "$@" &
PID=$!

trap 'kill -INT $PID' EXIT

# COULDDO: Read the port out of the environment?
# COULDDO: Read timeout limit from the environment?
/usr/local/bin/wait-for-it.sh --timeout=60 localhost:27017

if [ $? -eq 0 ]
then
  echo Initializing replica set...
  mongo --eval "rs.initiate()"
  wait
else
  echo "Timed out waiting for mongo to start."
  kill -INT $PID
  exit $E_UNAVAILABLE
fi
