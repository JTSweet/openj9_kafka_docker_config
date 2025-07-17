# Base image using IBM Semeru with OpenJ9 on Ubuntu Jammy
FROM ibm-semeru-runtimes:open-21-jre-jammy

# Set OpenJ9 specific JVM options as environment variables.
# This cleanly overrides the HotSpot defaults in kafka-run-class.sh.
# We are enabling class data sharing, a key OpenJ9 performance feature.
ENV KAFKA_JVM_PERFORMANCE_OPTS="-Xshareclasses:name=kafka,cacheDir=/opt/shareclasses -XX:+UseJITServer"

ENV KAFKA_HOME=/opt/kafka
ENV PATH="${KAFKA_HOME}/bin:${PATH}"

# Create a non-root user for security
RUN groupadd -r kafka && useradd -r -g kafka kafka

# Install necessary utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Copy the statically named Kafka distribution from the Jenkins workspace
COPY --chown=kafka:kafka kafka-distribution.tgz /tmp/

# Extract the archive and move its contents to a static directory
RUN tar -xzf /tmp/kafka-distribution.tgz -C /opt && \
    mv /opt/kafka_* ${KAFKA_HOME} && \
    rm /tmp/kafka-distribution.tgz

# FIX: Create and set permissions for essential directories
RUN mkdir -p /var/lib/kafka/data ${KAFKA_HOME}/logs /opt/shareclasses && \
    chown -R kafka:kafka /var/lib/kafka/data ${KAFKA_HOME}/logs /opt/shareclasses

# REMOVED: The patch command is no longer needed as we use ENV for JVM options.
# COPY kafka-run-class.patch /tmp/kafka-run-class.patch
# RUN patch ${KAFKA_HOME}/bin/kafka-run-class.sh < /tmp/kafka-run-class.patch \
#     && rm /tmp/kafka-run-class.patch

# Set the working directory and user
WORKDIR ${KAFKA_HOME}
USER kafka

# Expose ports
EXPOSE 9092 9093

# Use tini as the entrypoint to handle signals correctly
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["kafka-server-start.sh", "config/kraft/server.properties"]
