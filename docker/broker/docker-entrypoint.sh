#!/bin/bash
set -e

# Exit if any of the required KRaft environment variables are not set
if [[ -z "$KAFKA_PROCESS_ROLES" || -z "$KAFKA_NODE_ID" || -z "$KAFKA_CONTROLLER_QUORUM_VOTERS" ]]; then
    echo "ERROR: KAFKA_PROCESS_ROLES, KAFKA_NODE_ID, and KAFKA_CONTROLLER_QUORUM_VOTERS must be set."
    exit 1
fi

# Ensure log directory is set, default if not
KAFKA_LOG_DIRS=${KAFKA_LOG_DIRS:-/var/lib/kafka/data}

# Generate a Cluster ID if not provided

    echo "CLUSTER_ID not provided, generating a new one."
    CLUSTER_ID=$(uuidgen -r)
    echo "Generated CLUSTER_ID: ${CLUSTER_ID}"


# Unset all hardcoded JVM options from Kafka's default scripts
# This ensures that only the options provided by the user are used.
unset KAFKA_JVM_PERFORMANCE_OPTS
unset KAFKA_GC_LOG_OPTS

# Assemble OpenJ9 JVM options from environment variables
# This approach avoids any hardcoded HotSpot options.
JVM_OPTS=""

    JVM_OPTS="${JVM_OPTS} ${KAFKA_HEAP_OPTS}"
    # Export KAFKA_HEAP_OPTS to override the default in kafka-run-class.sh
    export KAFKA_HEAP_OPTS


    JVM_OPTS="${JVM_OPTS} ${KAFKA_JVM_PERFORMANCE_OPTS}"
    JVM_OPTS="${JVM_OPTS} ${KAFKA_GC_LOG_OPTS}"

# Append any generic KAFKA_OPTS

    JVM_OPTS="${JVM_OPTS} ${KAFKA_OPTS}"


# Export the final consolidated JVM options for kafka-run-class.sh to pick up

    export KAFKA_OPTS="${JVM_OPTS}"
    echo "Starting Kafka with OpenJ9 JVM Options: ${KAFKA_OPTS}"


# Execute the command passed to the entrypoint (e.g., kafka-server-start.sh)
# The 'exec' command replaces the shell process with the Kafka process,
# ensuring that Kafka becomes PID 1 and receives signals correctly.
exec "$@"
