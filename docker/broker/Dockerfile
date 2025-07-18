# Stage 1: JDK Provider
# Use the official IBM Semeru Runtimes image as a source for the JDK.
FROM ibm-semeru-runtimes:open-21.0.7_6-jdk-noble AS jdk_provider

# Stage 2: Final Image
# Start from the official Confluent Platform server image.
ARG CONFLUENT_VERSION=8.0.0
FROM confluentinc/cp-server:${CONFLUENT_VERSION}

# Define the target location for the new JDK inside the Confluent image.
ENV JAVA_HOME=/usr/lib/jvm/ibm-semeru-openj9-21

# Copy the OpenJ9 JDK from the 'jdk_provider' stage into the final image.
COPY --from=jdk_provider /opt/java/openjdk ${JAVA_HOME}

# Update the system's PATH to ensure that the new OpenJ9 'java' executable is found first.
ENV PATH="${JAVA_HOME}/bin:${PATH}"

#
# --- THE SUREFIRE MODIFICATION ---
#

RUN set -x \
    # 1. Ensure critical directories exist and have the correct permissions for the 'appuser'
    #    This is crucial for allowing Kafka to create and read the 'meta.properties' file.
    && mkdir -p /var/lib/kafka/data /var/lib/kafka/secrets \
    && chown -R appuser:appgroup /etc/kafka /var/lib/kafka/data /var/lib/kafka/secrets \
    # 2. Overwrite the original launch script with a new, controlled version.
    && echo '#!/bin/bash' > /etc/confluent/docker/launch \
    && echo 'set -x' >> /etc/confluent/docker/launch \
    # 3. Execute the original Confluent configuration and pre-flight scripts.
    #    This handles property file generation and KRaft storage formatting, which creates 'meta.properties'.
    && echo '/etc/confluent/docker/configure' >> /etc/confluent/docker/launch \
    && echo '/etc/confluent/docker/ensure' >> /etc/confluent/docker/launch \
    # 4. Execute the Java process directly, bypassing all Confluent wrapper scripts.
    #    This guarantees that ONLY the JVM arguments in KAFKA_JVM_ARGS are used.
    && echo 'exec ${JAVA_HOME}/bin/java ${KAFKA_JVM_ARGS} -cp "/usr/share/java/kafka/*:/usr/share/java/confluent-common/*:/usr/share/java/confluent-security/*" kafka.Kafka /etc/kafka/kafka.properties' >> /etc/confluent/docker/launch \
    # 5. Make the new launch script executable.
    && chmod +x /etc/confluent/docker/launch

# Optional: Verify the Java version at build time.
RUN java -version
