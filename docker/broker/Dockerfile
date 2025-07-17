# Base image using IBM Semeru with OpenJ9 on Ubuntu Jammy
FROM ibm-semeru-runtimes:open-21-jre-jammy AS builder

# Set a working directory to keep the build environment clean.
WORKDIR /tmp

# Set OpenJ9 specific JVM options as environment variables.
# This cleanly overrides the HotSpot defaults in kafka-run-class.sh.
# We are enabling class data sharing, a key OpenJ9 performance feature.
ENV KAFKA_JVM_PERFORMANCE_OPTS="-Xshareclasses:name=kafka,cacheDir=/opt/shareclasses -XX:+UseJITServer"

ENV KAFKA_HOME=/opt/kafka
ENV PATH="${KAFKA_HOME}/bin:${PATH}"

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
# Change ownership of the Kafka directory and make the entrypoint script executable.
RUN groupadd -r kafka && useradd -r -g kafka kafka && \
    chown -R kafka:kafka /opt/kafka && \
    chmod +x /docker-entrypoint.sh
    
# Copy the statically named Kafka distribution from the Jenkins workspace
COPY --chown=kafka:kafka kafka-distribution.tgz /tmp/

# Extract the archive and move its contents to a static directory
RUN tar -xzf /tmp/kafka-distribution.tgz -C /opt && \
    mv /opt/kafka_* ${KAFKA_HOME} && \
    rm /tmp/kafka-distribution.tgz

# FIX: Create and set permissions for essential directories
RUN mkdir -p /var/lib/kafka/data ${KAFKA_HOME}/logs /opt/shareclasses && \
    chown -R kafka:kafka /var/lib/kafka/data ${KAFKA_HOME}/logs /opt/shareclasses

# Set the working directory and user
WORKDIR ${KAFKA_HOME}
USER kafka

# Expose ports
EXPOSE 9092 9093

# Set the entrypoint to our custom script.
ENTRYPOINT ["/docker-entrypoint.sh"]

# Provide the default command that will be passed as arguments to the entrypoint script.
# This starts the Kafka server using the configuration file our script will create.
CMD ["kafka-server-start.sh", "config/kraft/server.properties"]
