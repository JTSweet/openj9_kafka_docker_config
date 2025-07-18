FROM ibm-semeru-runtimes:open-21-jdk-jammy

ENV KAFKA_HOME=/opt/kafka
ENV LANG=en_US.UTF-8
# Define a path for connectors that can be mounted via a volume
ENV KAFKA_CONNECT_PLUGINS_DIR=${KAFKA_HOME}/plugins

RUN groupadd -r kafka && useradd -r -g kafka -d ${KAFKA_HOME} -s /sbin/nologin kafka

RUN mkdir -p ${KAFKA_HOME} ${KAFKA_CONNECT_PLUGINS_DIR} /opt/kafka/scc && \
    chown -R kafka:kafka ${KAFKA_HOME} ${KAFKA_CONNECT_PLUGINS_DIR} /opt/kafka/scc

# Copy the pre-built Kafka artifacts
COPY --chown=kafka:kafka kafka-distribution.tgz /tmp/kafka.tgz

RUN tar -xzf /tmp/kafka.tgz -C ${KAFKA_HOME} --strip-components=1 && \
    rm /tmp/kafka.tgz

# Copy the entrypoint script
COPY --chown=kafka:kafka /docker/connect/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

USER kafka

# Expose a volume for adding connector plugins without rebuilding the image
VOLUME

# Expose the default Kafka Connect REST API port
EXPOSE 8083

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "connect-distributed.sh", "/opt/kafka/config/connect-distributed.properties" ]
