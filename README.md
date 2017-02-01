This variant of the official [mongo](https://hub.docker.com/_/mongo/) image provides:

 * replica set configuration required for proper operation
 * optional mounting of a host storage device useful when storing the mongodb data on an Amazon EBS volume

#### Environment Variables

 * `LOCAL_DEVICE`          : a filesystem device on the docker host. If specified, mounts the device to `/data/db`. Requires the container to run in privileged mode.
 * `SKIP_REPLICA_SET_INIT` : if defined, replica set initialization is skipped. Useful when using this image with an existing mongo db database.


Additional documentation and options for this image follow those of the [official image documentation](https://github.com/docker-library/docs/tree/master/mongo)
