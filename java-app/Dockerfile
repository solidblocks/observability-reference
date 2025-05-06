FROM gradle:8.7.0-jdk17 AS build
WORKDIR /app
COPY build.gradle settings.gradle ./
COPY gradlew ./
COPY gradle ./gradle/
COPY src ./src/
RUN ./gradlew build -x test --console=plain

FROM eclipse-temurin:17-jre
WORKDIR /app

# Download OpenTelemetry Java agent
RUN curl -L https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar -o /app/opentelemetry-javaagent.jar

COPY --from=build /app/build/libs/*.jar /app/app.jar

# Set up OpenTelemetry configuration
ENV JAVA_TOOL_OPTIONS="-javaagent:/app/opentelemetry-javaagent.jar"


EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"] 
