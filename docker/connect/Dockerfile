# Base image using IBM Semeru with OpenJ9 on Ubuntu Jammy
FROM ibm-semeru-runtimes:open-21-jdk-jammy

ARG KAFKA_VERSION
ARG SCALA_VERSION

ENV KAFKA_HOME=/opt/kafka
ENV PATH="${KAFKA_HOME}/bin:${PATH}"

# Create a non-root user
RUN groupadd -r kafka && useradd -r -g kafka kafka

# FIX: Install 'coreutils' which provides the 'timeout' command.
# Also install other necessary build tools.
RUN apt-get update && apt-get install -y --no-install-recommends \
    tini \
    git \
    patch \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

# Copy the Kafka distribution
COPY --chown=kafka:kafka kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz /tmp/
RUN tar -xzf /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt && \
    mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} && \
    rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

# Create directories for Connect plugins and set permissions
RUN mkdir -p ${KAFKA_HOME}/connect-plugins && chown -R kafka:kafka ${KAFKA_HOME}/connect-plugins

# Set working directory and user
WORKDIR ${KAFKA_HOME}
USER kafka

# Expose port
EXPOSE 8083

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["connect-distributed.sh", "config/connect-distributed.properties"]
