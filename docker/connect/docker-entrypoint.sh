#!/bin/bash
set -e

# If CONNECT_REST_ADVERTISED_HOST_NAME is not set, dynamically determine the container's IP.
# This is crucial for distributed mode in containerized environments.
if; then
    export CONNECT_REST_ADVERTISED_HOST_NAME=$(hostname -i)
fi
echo "Advertised REST Host Name: ${CONNECT_REST_ADVERTISED_HOST_NAME}"

# Execute the command passed to the entrypoint
exec "$@"
