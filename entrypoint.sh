#! /bin/bash
E_UNAVAILABLE=69
set -e

if [ -n "$LOCAL_DEVICE" ]; then
  # Mount LOCAL_DEVICE to /data/db, setting filesystem type and mount options if provided
	mount ${LOCAL_DEVICE_FS:+-t $LOCAL_DEVICE_FS} ${LOCAL_DEVICE_FS_OPTS:+-o $LOCAL_DEVICE_FS_OPTS} $LOCAL_DEVICE /data/db 
fi

chown -R mongodb /data/configdb /data/db

# COULDDO: Read the replica set name out of the environment?
gosu mongodb mongod "$@" &
PID=$!

trap 'kill -INT $PID' EXIT

# COULDDO: Read the port out of the environment?
# COULDDO: Read timeout limit from the environment?
/usr/local/bin/wait-for-it.sh --timeout=60 localhost:27017

if [ $? -eq 0 ]
then
  if [ -z "$SKIP_REPLICA_SET_INIT" ]; then
    echo Initializing replica set...
    mongo --eval "rs.initiate()"
  fi
  wait
else
  echo "Timed out waiting for mongo to start."
  kill -INT $PID
  exit $E_UNAVAILABLE
fi
