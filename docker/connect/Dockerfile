# Stage 1: Builder
FROM ibm-semeru-runtimes:open-21-jdk AS builder
WORKDIR /build
COPY..
RUN KAFKA_TGZ=$(find. -name 'kafka_*.tgz' | head -n 1) && \
    tar -xzf "$KAFKA_TGZ" -C /opt && \
    mv /opt/kafka_* /opt/kafka

# Stage 2: Final Image
# Use the full JDK base image for the final runtime to include diagnostic tools.
FROM ibm-semeru-runtimes:open-21-jdk
ENV KAFKA_HOME=/opt/kafka
ENV PATH=$PATH:$KAFKA_HOME/bin

# This is the crucial part for a flexible Connect image.
# Create a dedicated directory for connector plugins.
ENV CONNECT_PLUGIN_PATH=$KAFKA_HOME/plugins
RUN mkdir -p $CONNECT_PLUGIN_PATH

RUN groupadd -r kafka && useradd -r -g kafka kafka
COPY --from=builder /opt/kafka $KAFKA_HOME
COPY docker/connect/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown -R kafka:kafka $KAFKA_HOME

USER kafka
EXPOSE 8083

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["connect-distributed.sh", "/opt/kafka/config/connect-distributed.properties"]
