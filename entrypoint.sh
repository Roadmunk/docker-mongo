#! /bin/bash

set -e

if [ -n "$LOCAL_DEVICE" ]; then
	mount $LOCAL_DEVICE /data/db
fi

mongod "$@" &
PID=$!

trap 'kill -INT $PID' EXIT

sleep 10
mongo --eval "rs.initiate()"

wait
