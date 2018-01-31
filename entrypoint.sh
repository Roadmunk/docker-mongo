#! /bin/bash
set -euo pipefail
E_UNAVAILABLE=69
STARTUP_TIMEOUT="${STARTUP_TIMEOUT:-60}"

# Mount LOCAL_DEVICE to /data/db, setting filesystem type and mount options if provided
if [[ -n ${LOCAL_DEVICE:-} ]]; then
  mount ${LOCAL_DEVICE_FS:+-t $LOCAL_DEVICE_FS} ${LOCAL_DEVICE_FS_OPTS:+-o $LOCAL_DEVICE_FS_OPTS} $LOCAL_DEVICE /data/db

  # HACK: This is a not a great idea.
  # However, we can assert that our own snapshots were properly made, and cross
  # our fingers and just hope that the server using this option knows what it
  # is doing and doesn't spawn two mongos at once.
  if [${DELETE_MONGO_LOCK}]
  then
    rm -f /data/db/mongod.lock
  fi
fi

if [[ -n "${REPL_SET_INIT+1}" ]]; then
  echo "Not overriding REPL_SET_INIT";
else
  REPL_SET_INIT="none"
fi

chown -R mongodb /data/configdb /data/db

gosu mongodb mongod "$@" &
PID=$!

trap 'kill -INT $PID' EXIT

# COULDDO: Read the port out of the environment?
if !  /usr/local/bin/wait-for-it.sh --timeout=${STARTUP_TIMEOUT} localhost:27017; then
  echo "Timed out waiting for mongo to start."
  exit $E_UNAVAILABLE
fi

# If wait for it came back without error, continue by configuring replicaset.
case "$REPL_SET_INIT" in
  initiate|initiate_add)
    echo Initiating replica set...
    mongo --eval "rs.initiate()"
    ;;&

  initiate_add)
    until [[ $(mongo --quiet --eval 'JSON.stringify(rs.status())' | jq '.myState//6') == 1 ]]; do
      echo "Waiting to become primary..."
      echo "Current status: $(mongo --quiet --eval 'JSON.stringify(rs.status())' | jq '.myState//6')"
      sleep 5
    done

    for i in "${REPL_SET_MEMBERS[@]}"; do
      if /usr/local/bin/wait-for-it.sh --timeout=${STARTUP_TIMEOUT} ${i}:27017; then
        mongo --eval "rs.add(\"$i\")"
      else
        echo "Skipping replica set member ${i} due to timeout!"
      fi
    done
    if [[ -n ${REPL_SET_ARBITER:-} ]]; then
      if /usr/local/bin/wait-for-it.sh --timeout=${STARTUP_TIMEOUT} ${REPL_SET_ARBITER}:27017; then
        mongo --eval "rs.addArb(\"${REPL_SET_ARBITER}\")"
      else
        echo "Skipping replica set arbiter ${i} due to timeout!"
      fi
    fi
    ;;

  join_secondary)
    echo "Waiting for connection from primary"
    until [[ $(mongo --quiet --eval 'JSON.stringify(rs.status())' | jq '.myState//6') == 2 ]]
    do
      echo "Waiting to become secondary..."
      echo "Current status: $(mongo --quiet --eval 'JSON.stringify(rs.status())' | jq '.myState//6')"
      sleep 5
    done
    ;;

  join_arbiter)
    echo "Waiting for connection from primary"
    until [[ $(mongo --quiet --eval 'JSON.stringify(rs.status())' | jq '.myState//6') == 7 ]]
    do
      echo "Waiting to become arbiter..."
      echo "Current status: $(mongo --quiet --eval 'JSON.stringify(rs.status())' | jq '.myState//6')"
      sleep 5
    done
    ;;

  *)
    echo Skipping replica set initialization...

esac

wait
