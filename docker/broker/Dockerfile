# Stage 2: Final Kafka Image
FROM ibm-semeru-runtimes:open-21-jdk-jammy

# --- Step 1: Set up Environment Variables and Install Dependencies ---
# 1.1 Define environment variables for Kafka home and log directories
ENV KAFKA_HOME=/opt/kafka
ENV KAFKA_LOG_DIRS=/var/lib/kafka/data
ENV LANG=en_US.UTF-8

# 1.2 Install uuid-runtime for uuidgen command and clean up apt cache
RUN apt-get update && \
    apt-get install -y uuid-runtime && \
    rm -rf /var/lib/apt/lists/*

# 1.3 Add Kafka's bin directory to the PATH for easy command execution
ENV PATH="${KAFKA_HOME}/bin:${PATH}"

# --- Step 2: Create Kafka User and Directories ---
# 2.1 Create a dedicated non-root user and group for Kafka for security
RUN groupadd -r kafka && useradd -r -g kafka -d ${KAFKA_HOME} -s /sbin/nologin kafka

# 2.2 Create necessary directories and set appropriate permissions
RUN mkdir -p ${KAFKA_HOME} /var/lib/kafka/data /opt/kafka/scc && \
    chown -R kafka:kafka ${KAFKA_HOME} /var/lib/kafka/data /opt/kafka/scc

# --- Step 3: Copy and Extract Kafka Distribution ---
# 3.1 Copy the pre-built Kafka artifacts into the build context
COPY --chown=kafka:kafka kafka-distribution.tgz /tmp/kafka.tgz

# 3.2 Extract Kafka and remove the temporary archive
RUN tar -xzf /tmp/kafka.tgz -C ${KAFKA_HOME} --strip-components=1 && \
    rm /tmp/kafka.tgz

# 3.3 Set executable permissions for Kafka scripts
RUN chmod +x ${KAFKA_HOME}/bin/*.sh

# --- Step 4: Configure Server Properties and Entrypoint ---
# 4.1 Confirm the location of the default server.properties file
#     This RUN command will list the contents of the config directory,
#     and the output will be visible during the Docker build process.
RUN ls -l ${KAFKA_HOME}/config/

# 4.2 Copy the default server.properties to the /opt/kafka/config/kraft directory
RUN cp ${KAFKA_HOME}/config/server.properties ${KAFKA_HOME}/config/kraft/server.properties 

RUN chown kafka:kafka ${KAFKA_HOME}/config/kraft/server.properties

# 4.3 Copy the custom entrypoint script and set permissions
COPY --chown=kafka:kafka docker/broker/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# 4.4 Switch to the non-root Kafka user
USER kafka

# 4.5 Declare a volume for persistent Kafka log data (for data durability)
VOLUME [ "/var/lib/kafka/data" ]

# 4.6 Expose ports for client connections (9092) and KRaft controller quorum (9093)
EXPOSE 9092 9093

# 4.7 Set the entrypoint to the custom script
ENTRYPOINT [ "/docker-entrypoint.sh" ]

# 4.8 Define the default command to start the Kafka server
CMD [ "kafka-server-start.sh", "/opt/kafka/config/kraft/server.properties" ]
