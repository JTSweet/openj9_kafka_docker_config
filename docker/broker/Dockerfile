# Stage 1: Build the final image
FROM ibm-semeru-runtimes:open-21-jdk-jammy

# Define environment variables
ENV KAFKA_HOME=/opt/kafka
ENV KAFKA_LOG_DIRS=/var/lib/kafka/data
ENV LANG=en_US.UTF-8

# Create a dedicated non-root user and group for Kafka
RUN groupadd -r kafka && useradd -r -g kafka -d ${KAFKA_HOME} -s /sbin/nologin kafka

# Install uuid-runtime for uuidgen command
RUN sudo apt update
RUN sudo apt install -y uuid-runtime

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
COPY --chown=kafka:kafka /docker/broker/docker-entrypoint.sh /
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
