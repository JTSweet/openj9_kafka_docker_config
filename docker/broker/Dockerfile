# Use the official IBM Semeru Runtime with OpenJ9 JDK 21 as the base image
FROM ibm-semeru-runtimes:open-21.0.7_6-jdk-jammy AS builder

# Set environment variables
ENV KAFKA_VERSION=4.0.0
ENV SCALA_VERSION=2.13
ENV KAFKA_HOME=/opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}
ENV PATH=${KAFKA_HOME}/bin:${PATH}

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    gradle \
    patch \
    && rm -rf /var/lib/apt/lists/*

# Clone Apache Kafka repository
WORKDIR /usr/src
RUN git clone --depth 1 --branch ${KAFKA_VERSION} https://github.com/apache/kafka.git

# Build Kafka from source
WORKDIR /usr/src/kafka
RUN ./gradlew releaseTarGz

# Unpack the built Kafka distribution and clean up
RUN tar -xzf /usr/src/kafka/core/build/distributions/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
    && rm -rf /usr/src/kafka \
    && rm -rf /root/.gradle

# --- JVM Customization ---

# Copy the patch file into the image
COPY docker/broker/kafka-run-class.patch /tmp/

# Apply the patch to the kafka-run-class.sh script
RUN patch ${KAFKA_HOME}/bin/kafka-run-class.sh < /tmp/kafka-run-class.patch \
    && rm /tmp/kafka-run-class.patch

# --- Class Data Sharing (CDS) Cache Priming ---

# Create a directory for the persistent shared class cache
RUN mkdir -p /opt/share/class_cache && chmod -R 777 /opt/share/class_cache

# Prime the CDS cache by running the server briefly.
# This populates the cache with core Kafka classes for faster startup.
# We use a minimal heap and expect it to exit with a non-zero code via timeout.
RUN KAFKA_HEAP_OPTS="-Xmx256m -Xms256m" \
    KAFKA_OPTS="-Xshareclasses:name=kafka,cacheDir=/opt/share/class_cache,persistent" \
    timeout 60s kafka-server-start.sh ${KAFKA_HOME}/config/kraft/server.properties 

RUN echo "CDS priming run completed."

# --- Final Container Configuration ---

# Copy a generic, simplified entrypoint script
COPY docker/broker/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# Expose Kafka ports
EXPOSE 9092 9093

# Set the entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]

# Default command to start a Kafka broker
CMD ["kafka-server-start.sh", "/opt/kafka_2.13-4.0.0/config/kraft/server.properties"]
