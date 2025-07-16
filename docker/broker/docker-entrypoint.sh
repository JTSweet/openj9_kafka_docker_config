#!/bin/bash
set -e

# If KAFKA_CLUSTER_ID is not set, generate a new random UUID.
# This is required for the first-time format of a new KRaft cluster.
if [ -z $KAFKA_CLUSTER_ID] ; then
    export KAFKA_CLUSTER_ID=$(kafka-storage.sh random-uuid)
fi
echo "Kafka Cluster ID: ${KAFKA_CLUSTER_ID}"

# Format the storage directory if it hasn't been formatted before.
# Ensure the data directory path matches your server.properties log.dirs config.
if [! -f "/tmp/kraft-combined-logs/meta.properties" ]; then
    echo "Formatting storage directory..."
    kafka-storage.sh format -t "$KAFKA_CLUSTER_ID" -c "$KAFKA_HOME/config/kraft/server.properties"
fi

# The KAFKA_OPTS for OpenJ9 are now set automatically by the patched
# kafka-run-class.sh script. No need to set them here.

# Execute the command passed to the entrypoint (e.g., kafka-server-start.sh)
exec "$@"
