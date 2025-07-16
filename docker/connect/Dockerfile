# Use the official IBM Semeru Runtime with OpenJ9 JDK 21 as the base image
FROM ibm-semeru-runtimes:open-21.0.7_6-jdk-jammy AS builder

# Set environment variables for Kafka version and home directory
ENV KAFKA_VERSION=4.0.0
ENV SCALA_VERSION=2.13
ENV KAFKA_HOME=/opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}
ENV PATH=${KAFKA_HOME}/bin:${PATH}

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gradle \
    patch \
    timeout \
    && rm -rf /var/lib/apt/lists/*

# Clone Apache Kafka repository
WORKDIR /usr/src
RUN git clone --depth 1 --branch ${KAFKA_VERSION} https://github.com/apache/kafka.git

# Build Kafka from source using Gradle
WORKDIR /usr/src/kafka
RUN ./gradlew releaseTarGz

# Unpack the built Kafka distribution and clean up build artifacts
RUN tar -xzf /usr/src/kafka/core/build/distributions/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
    && rm -rf /usr/src/kafka \
    && rm -rf /root/.gradle

# --- JVM Customization for OpenJ9 ---

# Copy the universal patch file into the image
COPY kafka-run-class.patch /tmp/

# Apply the patch to the kafka-run-class.sh script
RUN patch ${KAFKA_HOME}/bin/kafka-run-class.sh < /tmp/kafka-run-class.patch \
    && rm /tmp/kafka-run-class.patch

# --- Kafka Connect Specific Configuration ---

# Create a directory for the persistent shared class cache
RUN mkdir -p /opt/share/class_cache && chmod -R 777 /opt/share/class_cache

# Copy a minimal properties file needed for the cache priming step
COPY connect-distributed-prime.properties ${KAFKA_HOME}/config/

# Prime the Class Data Sharing (CDS) cache by running Kafka Connect briefly.
# This populates the cache with Connect-specific classes for faster startup.
# We set a unique cache name for Connect to avoid conflicts with other components.
RUN export KAFKA_CDS_CACHE_NAME="kafka-connect" && \
    export KAFKA_HEAP_OPTS="-Xmx256m -Xms256m" && \
    export KAFKA_OPTS="-Xshareclasses:name=${KAFKA_CDS_CACHE_NAME},cacheDir=/opt/share/class_cache,persistent" && \
    timeout 60s connect-distributed.sh ${KAFKA_HOME}/config/connect-distributed-prime.properties 

RUN echo "CDS priming run for Kafka Connect completed."

# --- Final Container Configuration ---

# Copy the simplified entrypoint script for Kafka Connect
COPY docker/connect/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# Expose the default Kafka Connect REST API port
EXPOSE 8083

# Set the entrypoint
ENTRYPOINT ["/connect-docker-entrypoint.sh"]

# Default command to start a Kafka Connect worker
# Note: The properties file path should be mounted via a volume in production.
