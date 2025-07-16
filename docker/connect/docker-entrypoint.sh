#!/bin/bash
set -e

# If CONNECT_REST_ADVERTISED_HOST_NAME is not set, dynamically determine the container's IP.
# This is crucial for distributed mode in containerized environments.
if -z "${CONNECT_REST_ADVERTISED_HOST_NAME}"; then
    export CONNECT_REST_ADVERTISED_HOST_NAME=$(hostname -i)
fi
echo "Advertised REST Host Name: ${CONNECT_REST_ADVERTISED_HOST_NAME}"

# Set OpenJ9 specific JVM options
export KAFKA_OPTS="-Xshareclasses -Xquickstart -Xgcpolicy:gencon"

# Execute the command passed to the entrypoint
exec "$@"
