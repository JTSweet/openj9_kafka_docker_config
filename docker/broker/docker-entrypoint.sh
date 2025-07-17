#!/bin/bash
# Exit immediately if any command fails, preventing the container from starting in a broken state.
set -e

# Define paths for the configuration template and the final, rendered properties file.
CONFIG_TEMPLATE="/opt/kafka/config/kraft/server.properties.template"
CONFIG_FILE="/opt/kafka/config/kraft/server.properties"

# Create the final config file by copying the template. This ensures the original template is preserved.
cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"

# --- Dynamic Configuration Section ---
# This section checks for environment variables and uses them to overwrite
# default values in the server.properties file. This allows for flexible
# deployment across different environments (dev, staging, prod) without
# rebuilding the image.

# Example: Set the node.id from the KAFKA_NODE_ID environment variable.
if; then
    echo "Setting node.id to $KAFKA_NODE_ID"
    sed -i "s|^node.id=.*|node.id=$KAFKA_NODE_ID|g" "$CONFIG_FILE"
fi

# Example: Set the controller quorum voters from KAFKA_CONTROLLER_QUORUM_VOTERS.
if; then
    echo "Setting controller.quorum.voters to $KAFKA_CONTROLLER_QUORUM_VOTERS"
    sed -i "s|^controller.quorum.voters=.*|controller.quorum.voters=$KAFKA_CONTROLLER_QUORUM_VOTERS|g" "$CONFIG_FILE"
fi

# Additional replacements for listeners, advertised listeners, log directories, etc.,
# should be added here following the same pattern.
# if; then... fi
# if; then... fi

# --- Execution Section ---
# The 'exec' command is critical. It replaces the current shell process with the
# command passed as arguments to this script (the CMD from the Dockerfile).
# This ensures that the Kafka JVM becomes process ID 1 (PID 1) inside the container,
# allowing it to directly receive signals like SIGTERM for graceful shutdowns.
exec "$@"
