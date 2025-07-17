# Base image using IBM Semeru with OpenJ9 on Ubuntu Jammy
FROM ibm-semeru-runtimes:open-21-jre-jammy AS builder

# Use ARGs to allow the Kafka and Scala versions to be passed in from the 'docker build' command.
# This makes the Dockerfile more reusable and independent of hardcoded versions.
ARG KAFKA_VERSION=4.2.0-SNAPSHOT
ARG SCALA_VERSION=2.13

# Set a working directory to keep the build environment clean.
WORKDIR /tmp

# Copy the Kafka.tgz file created by the Gradle 'releaseTarGz' task from the build context.
# The path 'core/build/distributions/' is relative to the Jenkins workspace root where the build occurs.
# A space is required between the source file and the destination directory ('.').
COPY core/build/distributions/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz .

# Unpack the archive. Then, create a symbolic link to a clean, version-independent path (/opt/kafka).
# This simplifies downstream paths. Finally, remove the archive to keep the layer clean.
RUN tar -xzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    ln -s /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka && \
    rm kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

# ---

# Stage 2: Final Image - This stage builds the lean, production-ready image.
# It starts from a minimal IBM Semeru JRE base image to reduce size and attack surface.
FROM ibm-semeru-runtimes:open-21-jre-jammy

# Set environment variables for the Kafka home directory and add its 'bin' to the system PATH.
ENV KAFKA_HOME=/opt/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

# Copy the extracted Kafka application from the 'builder' stage into the final image.
# This is the core of the multi-stage pattern; no build tools or source code are included.
COPY --from=builder /opt/kafka /opt/kafka

# Copy the custom entrypoint script and the server properties template into the image.
# The properties file is named '.template' to indicate it will be processed by the entrypoint.
# These paths are relative to the build context (the Jenkins workspace root).
COPY docker/broker/docker-entrypoint.sh /
COPY docker/broker/server.properties /opt/kafka/config/kraft/server.properties.template

# Create a dedicated, non-root user ('kafka') for running the application.
# This is a critical security best practice to limit the potential impact of a container compromise.
RUN groupadd -r kafka && useradd -r -g kafka kafka

# --- OpenJ9 Optimizations ---
# Create a directory for the Shared Class Cache (SCC).
# Populate the SCC by running a command that loads Kafka classes. This creates a read-only cache layer
# in the image, significantly improving startup time and reducing memory footprint for all containers
# created from this image.
RUN mkdir /opt/kafka/scc && \
    chown -R kafka:kafka /opt/kafka && \
    /opt/kafka/bin/kafka-storage.sh --version && \
    chmod +x /docker-entrypoint.sh

# Set default KAFKA_OPTS with recommended IBM Semeru OpenJ9 settings.
# These options are tailored for containerized, low-latency workloads like Kafka and are distinct
# from HotSpot JVM tuning parameters.
# -XX:+UseContainerSupport: Ensures the JVM respects container memory limits.
# -Xshareclasses: Uses the Shared Class Cache created during the build for faster startup.
# -Xgcpolicy:gencon: Uses the generational concurrent garbage collector, ideal for responsive applications.
# -Xdisableexplicitgc: Prevents application code from forcing disruptive garbage collection cycles.
# -Xtune:virtualized: Optimizes the JVM for running in a cloud/virtualized environment.
ENV KAFKA_OPTS="-XX:+UseContainerSupport -Xshareclasses:name=kafka,cacheDir=/opt/kafka/scc,readonly,nonfatal -Xgcpolicy:gencon -Xdisableexplicitgc -Xtune:virtualized"

# Switch the active user from 'root' to the newly created 'kafka' user.
USER kafka

# Set the working directory to the Kafka home directory for the running process.
WORKDIR $KAFKA_HOME

# Provide the default command that will be passed as arguments to the entrypoint script.
# This starts the Kafka server using the configuration file our script will create.
CMD ["kafka-server-start.sh", "config/kraft/server.properties"]
