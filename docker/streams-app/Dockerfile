# Stage 1: Build the application
FROM maven:3.8-ibm-semeru-21-jdk AS builder

WORKDIR /app
COPY pom.xml.
COPY src./src

# Build the application and create a fat JAR
RUN mvn clean package

# Stage 2: Final Image
# Use the full JDK base image for the final runtime to include diagnostic tools.
FROM ibm-semeru-runtimes:open-21-jdk

WORKDIR /app

# Copy the application JAR from the builder stage
COPY --from=builder /app/target/wordcount-app-1.0-SNAPSHOT.jar.

# The bootstrap servers will be passed via environment variable
ENV KAFKA_BOOTSTRAP_SERVERS="kafka-1:9092"

CMD
