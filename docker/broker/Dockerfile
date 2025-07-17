# Base image using IBM Semeru with OpenJ9 on Ubuntu Jammy
FROM ibm-semeru-runtimes:open-21-jre-jammy

ARG KAFKA_VERSION
ARG SCALA_VERSION

ENV KAFKA_HOME=/opt/kafka
ENV PATH="${KAFKA_HOME}/bin:${PATH}"

# Create a non-root user for security
RUN groupadd -r kafka && useradd -r -g kafka kafka

# Install necessary utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Copy the Kafka distribution built in the Jenkins pipeline
COPY --chown=kafka:kafka kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz /tmp/
RUN tar -xzf /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt && \
    mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} && \
    rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

# FIX: Use sed for a robust, self-contained modification of the startup script.
# This is more reliable than using an external patch file.
# This example prepends OpenJ9-specific options for class sharing to the performance flags.
RUN sed -i '/^KAFKA_JVM_PERFORMANCE_OPTS=/ s/"$/ -Xshareclasses:name=kafka,cacheDir=\/opt\/shareclasses -XX:+UseJITServer"/' ${KAFKA_HOME}/bin/kafka-run-class.sh

# Create directories for data and set permissions
RUN mkdir -p /var/lib/kafka/data && chown -R kafka:kafka /var/lib/kafka/data

# Set the working directory and user
WORKDIR ${KAFKA_HOME}
USER kafka

# Expose ports
EXPOSE 9092 9093

# Use tini as the entrypoint to handle signals correctly
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["kafka-server-start.sh", "config/kraft/server.properties"]
