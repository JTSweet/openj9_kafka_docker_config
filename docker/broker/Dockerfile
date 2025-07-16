# Stage 1: Builder
# Use the full JDK image to extract the Kafka distribution.
FROM ibm-semeru-runtimes:open-21-jdk AS builder

WORKDIR /build

# Copy the entire source code context which includes the distribution tarball.
COPY..

# Find the distribution tarball and extract it.
RUN KAFKA_TGZ=$(find. -name 'kafka_*.tgz' | head -n 1) && \
    tar -xzf "$KAFKA_TGZ" -C /opt && \
    # Rename the extracted directory to a predictable name.
    mv /opt/kafka_* /opt/kafka

# Stage 2: Final Image
# Use the full JDK base image for the final runtime to include diagnostic tools
# such as jcmd for generating heap dumps or thread dumps (javacores).
FROM ibm-semeru-runtimes:open-21-jdk

ENV KAFKA_HOME=/opt/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

# Create a non-root user and group for security.
RUN groupadd -r kafka && useradd -r -g kafka kafka

# Copy only the necessary files from the builder stage.
COPY --from=builder /opt/kafka $KAFKA_HOME

# Copy the custom entrypoint script.
COPY docker/broker/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create data directory and set ownership to the kafka user.
RUN mkdir -p /var/lib/kafka/data && \
    chown -R kafka:kafka /var/lib/kafka && \
    chown -R kafka:kafka $KAFKA_HOME

# Switch to the non-root user.
USER kafka

VOLUME ["/var/lib/kafka/data"]

# Expose ports for client connections and the KRaft controller protocol.
EXPOSE 9092 9093

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["kafka-server-start.sh", "/opt/kafka/config/kraft/server.properties"]
