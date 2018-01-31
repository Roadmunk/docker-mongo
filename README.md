This variant of the official [mongo](https://hub.docker.com/_/mongo/) image provides:

 * replica set configuration required for proper operation
 * optional mounting of a host storage device useful when storing the mongodb data on an Amazon EBS volume
 * a healthcheck that returns ServerStatus

#### Usage in docker-compose

You can use this image just like any other image in docker-compose.
To be able to pass command line arguments to mongo you need to update the `command` section of the service

Sample docker-compose file
```
version: "2"
services:
  mongo:
      image: roadmunk/mongo:<versionNumber>
      command: --dbpath <path> --replset <name>
```

Refer to [mongod options documentation](https://docs.mongodb.com/manual/reference/program/mongod/)

#### Environment Variables

 * `DELETE_MONGO_LOCK`: force deletes the mongod.lock file
 * `LOCAL_DEVICE`: attempt to mount this device path on `/data/db`; requires the container to run in privileged mode
 * `REPL_SET_INIT`: set the initialization behaviour of the container's replica set
    * `initiate`: run `rs.initiate()`
    * `initiate_add`: run `rs.initiate()` then `rs.add([value])` for every value in `REPL_SET_MEMBERS`
    * `join_secondary`: wait for this container to become a replica set secondary
    * `join_arbiter`: wait for this container to become a replica set arbiter
    * any other value or unset: no replica set is configured and `REPL_SET_MEMBERS` is ignored
 * `RECONFIG_REPL_SET_NAME`: the replica set name to use; only used when `REPL_SET_INIT` is `reconfig`.
 * `REPL_SET_MEMBERS`: list of hosts to add as replica set secondaries; only used when `REPL_SET_INIT` is `initiate_add`.
 * `REPL_SET_ARBITER`: host to add as a replica set arbiter; only used when `REPL_SET_INIT` is `initiate_add`.

Additional documentation and options for this image follow those of the [official image documentation](https://github.com/docker-library/docs/tree/master/mongo)