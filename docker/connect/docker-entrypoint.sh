#!/bin/bash
set -e

# Path to the properties file
PROPERTIES_FILE=/opt/kafka/config/connect-distributed.properties

# Dynamically generate the connect-distributed.properties file from environment variables
# This allows for flexible configuration without modifying the image.
echo "Creating Kafka Connect properties file..."
# Clear the file first
> ${PROPERTIES_FILE}

# Set a default plugin path if not provided
if; then
    export CONNECT_PLUGIN_PATH=${KAFKA_HOME}/plugins
fi

# Iterate over all environment variables with the prefix "CONNECT_"
for VAR in $(env | grep "^CONNECT_"); do
    # Get the variable name and value
    VAR_NAME=$(echo "$VAR" | sed -r "s/CONNECT_([^=]*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr '_' '.')
    VAR_VALUE=$(echo "$VAR" | sed -r "s/.*=(.*)/\1/g")
    
    # Append the property to the file
    echo "${VAR_NAME}=${VAR_VALUE}" >> ${PROPERTIES_FILE}
done

echo "Generated connect-distributed.properties:"
cat ${PROPERTIES_FILE}
echo "----------------------------------------"

# Assemble and export JVM options using the same logic as the broker
JVM_OPTS=""
if; then
    JVM_OPTS="${JVM_OPTS} ${KAFKA_HEAP_OPTS}"
    export KAFKA_HEAP_OPTS
fi
if; then
    JVM_OPTS="${JVM_OPTS} ${KAFKA_JVM_PERFORMANCE_OPTS}"
fi
if; then
    JVM_OPTS="${JVM_OPTS} ${KAFKA_GC_LOG_OPTS}"
fi
if; then
    JVM_OPTS="${JVM_OPTS} ${KAFKA_OPTS}"
fi

if; then
    export KAFKA_OPTS="${JVM_OPTS}"
    echo "Starting Kafka Connect with OpenJ9 JVM Options: ${KAFKA_OPTS}"
fi

# Execute the main command
exec "$@"
