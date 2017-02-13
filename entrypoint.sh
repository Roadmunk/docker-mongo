#! /bin/bash
E_UNAVAILABLE=69
set -e

if [ -n "$LOCAL_DEVICE" ]; then
  # Mount LOCAL_DEVICE to /data/db, setting filesystem type and mount options if provided
	mount ${LOCAL_DEVICE_FS:+-t $LOCAL_DEVICE_FS} ${LOCAL_DEVICE_FS_OPTS:+-o $LOCAL_DEVICE_FS_OPTS} $LOCAL_DEVICE /data/db 
fi

if [ -z "$REPL_SET_NAME" ]; then
  REPL_SET_NAME=development
fi

chown -R mongodb /data/configdb /data/db

OPTIONS=
if [ -n "$REPL_SET_INIT" ]; then
  OPTIONS="--replSet=$REPL_SET_NAME"
fi

gosu mongodb mongod $OPTIONS $@ &
PID=$!

trap 'kill -INT $PID' EXIT

# COULDDO: Read the port out of the environment?
# COULDDO: Read timeout limit from the environment?
/usr/local/bin/wait-for-it.sh --timeout=60 localhost:27017

if [ $? -eq 0 ]
then
  if [ "$REPL_SET_INIT" == "initiate" ]; then
    echo Initiating replica set...
    mongo --eval "rs.initiate()"
  elif [ "$REPL_SET_INIT" == "reconfig" ]; then
    echo Reconfiguring replica set...
    mongo --eval "rs.reconfig({ _id : \'$REPL_SET_NAME\', version : 1, members : [ { _id : 1, host: \'localhost\' } ]}, { force : true })"
  else
    echo Skipping replica set initialization...
  fi
  wait
else
  echo "Timed out waiting for mongo to start."
  kill -INT $PID
  exit $E_UNAVAILABLE
fi
