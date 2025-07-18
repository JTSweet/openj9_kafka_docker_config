# Stage 1: (This stage is not strictly necessary for uuidgen in the final image as written,
# but if you had other build artifacts from this stage that were copied, you'd keep it.)
FROM ubuntu:22.04 AS build_stage

# Update the package lists and install uuid-runtime (This is now redundant for the final image)
RUN apt-get update && apt-get install -y uuid-runtime

# You can optionally remove the apt cache to reduce image size (Also redundant for the final image)
RUN rm -rf /var/lib/apt/lists/*

# Your application code or other commands can go here
# For example, you can demonstrate using uuidgen
CMD ["uuidgen"]


# Stage 2: Build the final image
FROM ibm-semeru-runtimes:open-21-jdk-jammy

# Define environment variables
ENV KAFKA_HOME=/opt/kafka
ENV KAFKA_LOG_DIRS=/var/lib/kafka/data
ENV LANG=en_US.UTF-8

# Install uuid-runtime in the final stage
RUN apt-get update && \
    apt-get install -y uuid-runtime && \
    rm -rf /var/lib/apt/lists/*

# Create a dedicated non-root user and group for Kafka
RUN groupadd -r kafka && useradd -r -g kafka -d ${KAFKA_HOME} -s /sbin/nologin kafka

# Create necessary directories and set permissions
RUN mkdir -p ${KAFKA_HOME} /var/lib/kafka/data /opt/kafka/scc && \
    chown -R kafka:kafka ${KAFKA_HOME} /var/lib/kafka/data /opt/kafka/scc

# Copy the pre-built Kafka artifacts from your Jenkins build stage
# Ensure the artifacts are placed in a location accessible to the Docker build context
COPY --chown=kafka:kafka kafka-distribution.tgz /tmp/kafka.tgz

# Extract Kafka and clean up
RUN tar -xzf /tmp/kafka.tgz -C ${KAFKA_HOME} --strip-components=1 && \
    rm /tmp/kafka.tgz

# Copy the entrypoint script and set permissions
COPY --chown=kafka:kafka docker/broker/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Switch to the non-root user
USER kafka

# Declare a volume for persistent Kafka log data
VOLUME [ "/var/lib/kafka/data" ]

# Expose ports for client connections (9092) and KRaft controller quorum (9093)
EXPOSE 9092 9093

# Set the entrypoint to our custom script
ENTRYPOINT [ "/docker-entrypoint.sh" ]

# Define the default command to start the Kafka server
CMD [ "kafka-server-start.sh", "/opt/kafka/config/kraft/server.properties" ]
