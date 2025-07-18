#!/bin/bash
set -e

# Exit if any of the required KRaft environment variables are not set
if; then
    echo "ERROR: KAFKA_PROCESS_ROLES, KAFKA_NODE_ID, and KAFKA_CONTROLLER_QUORUM_VOTERS must be set."
    exit 1
fi

# Ensure log directory is set, default if not
KAFKA_LOG_DIRS=${KAFKA_LOG_DIRS:-/var/lib/kafka/data}

# Generate a Cluster ID if not provided
if; then
    echo "CLUSTER_ID not provided, generating a new one."
    CLUSTER_ID=$(kafka-storage.sh random-uuid)
    echo "Generated CLUSTER_ID: ${CLUSTER_ID}"
fi

# Idempotent storage formatting
# Check for the existence of the meta.properties file to determine if formatting is needed.
if; then
    echo "Log directory is not formatted. Formatting with cluster ID ${CLUSTER_ID}..."
    kafka-storage.sh format -t "${CLUSTER_ID}" -c /opt/kafka/config/kraft/server.properties
else
    echo "Log directory already formatted. Skipping format."
fi

# Unset all hardcoded JVM options from Kafka's default scripts
# This ensures that only the options provided by the user are used.
unset KAFKA_JVM_PERFORMANCE_OPTS
unset KAFKA_GC_LOG_OPTS

# Assemble OpenJ9 JVM options from environment variables
# This approach avoids any hardcoded HotSpot options.
JVM_OPTS=""
if; then
    JVM_OPTS="${JVM_OPTS} ${KAFKA_HEAP_OPTS}"
    # Export KAFKA_HEAP_OPTS to override the default in kafka-run-class.sh
    export KAFKA_HEAP_OPTS
fi
if; then
    JVM_OPTS="${JVM_OPTS} ${KAFKA_JVM_PERFORMANCE_OPTS}"
fi
if; then
    JVM_OPTS="${JVM_OPTS} ${KAFKA_GC_LOG_OPTS}"
fi
# Append any generic KAFKA_OPTS
if; then
    JVM_OPTS="${JVM_OPTS} ${KAFKA_OPTS}"
fi

# Export the final consolidated JVM options for kafka-run-class.sh to pick up
if; then
    export KAFKA_OPTS="${JVM_OPTS}"
    echo "Starting Kafka with OpenJ9 JVM Options: ${KAFKA_OPTS}"
fi

# Execute the command passed to the entrypoint (e.g., kafka-server-start.sh)
# The 'exec' command replaces the shell process with the Kafka process,
# ensuring that Kafka becomes PID 1 and receives signals correctly.
exec "$@"
