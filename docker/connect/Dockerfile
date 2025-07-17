# Base image using IBM Semeru with OpenJ9 on Ubuntu Jammy
FROM ibm-semeru-runtimes:open-21-jdk-jammy

# ARG declarations are no longer needed for the filename
# ARG KAFKA_VERSION
# ARG SCALA_VERSION

ENV KAFKA_HOME=/opt/kafka
ENV PATH="${KAFKA_HOME}/bin:${PATH}"

# Create a non-root user
RUN groupadd -r kafka && useradd -r -g kafka kafka

# FIX: Install 'coreutils' which provides the 'timeout' command.
RUN apt-get update && apt-get install -y --no-install-recommends \
    tini \
    git \
    patch \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

# FIX: Copy the statically named Kafka distribution from the Jenkins workspace
COPY --chown=kafka:kafka kafka-distribution.tgz /tmp/

# FIX: Extract the archive and move its contents from the dynamic folder name
# inside the tarball to the static KAFKA_HOME directory.
RUN tar -xzf /tmp/kafka-distribution.tgz -C /opt && \
    mv /opt/kafka_* ${KAFKA_HOME} && \
    rm /tmp/kafka-distribution.tgz

# Create directories for Connect plugins and set permissions
RUN mkdir -p ${KAFKA_HOME}/connect-plugins && chown -R kafka:kafka ${KAFKA_HOME}/connect-plugins

# Set working directory and user
WORKDIR ${KAFKA_HOME}
USER kafka

# Expose port
EXPOSE 8083

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["connect-distributed.sh", "config/connect-distributed.properties"]
