# Base image using IBM Semeru with OpenJ9 on Ubuntu Jammy
FROM ibm-semeru-runtimes:open-21-jdk-jammy

# Set OpenJ9 specific JVM options as environment variables.
ENV KAFKA_JVM_PERFORMANCE_OPTS="-Xshareclasses:name=kafka-connect,cacheDir=/opt/shareclasses -XX:+UseJITServer"

ENV KAFKA_HOME=/opt/kafka
ENV PATH="${KAFKA_HOME}/bin:${PATH}"

# Create a non-root user
RUN groupadd -r kafka && useradd -r -g kafka kafka

# Install necessary build tools, including 'coreutils' for the 'timeout' command.
RUN apt-get update && apt-get install -y --no-install-recommends \
    tini \
    git \
    patch \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

# Copy the statically named Kafka distribution
COPY --chown=kafka:kafka kafka-distribution.tgz /tmp/

# Extract the archive and move its contents to a static directory
RUN tar -xzf /tmp/kafka-distribution.tgz -C /opt && \
    mv /opt/kafka_* ${KAFKA_HOME} && \
    rm /tmp/kafka-distribution.tgz

# FIX: Create and set permissions for essential directories
RUN mkdir -p ${KAFKA_HOME}/connect-plugins /opt/shareclasses && \
    chown -R kafka:kafka ${KAFKA_HOME}/connect-plugins /opt/shareclasses

# Set working directory and user
WORKDIR ${KAFKA_HOME}
USER kafka

# Expose port
EXPOSE 8083

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["connect-distributed.sh", "config/connect-distributed.properties"]
