# Stage 1: Build the application
FROM ibm-semeru-runtimes:open-21.0.7_6-jdk-jammy AS builder

WORKDIR /app
COPY pom.xml .
COPY src ./src

# Build the application and create a fat JAR
RUN mvn clean package

# Stage 2: Final Image
# Use the full JDK base image for the final runtime to include diagnostic tools.
FROM ibm-semeru-runtimes:open-21.0.7_6-jdk-jammy

# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy the fat JAR from the builder stage
COPY --from=builder /app/target/kafka-streams-wordcount-*.jar./app.jar

# Set user
USER appuser

# Define the command to run the application
CMD ["java", "-jar", "app.jar"]
