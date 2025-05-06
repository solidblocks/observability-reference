# Java Application with OpenTelemetry

This is a simple Java application instrumented with OpenTelemetry.

## Prerequisites

- Docker and Docker Compose
- OpenTelemetry Collector accessible on port 4318

## Running the Application

To start the application:

```bash
make start
```

This will build and start the application container. The application will be available on port 18080.

## OpenTelemetry Configuration

The application requires an OpenTelemetry collector to be running and accessible on port 4318. It exports traces via OTLP protocol to this endpoint.

## Testing the Application

Access the application at:
- Application endpoint: http://localhost:18080
- Actuator endpoints: http://localhost:18080/actuator
- Prometheus metrics: http://localhost:18080/actuator/prometheus

Send a request to generate some telemetry:
```bash
curl http://localhost:18080/hello/world
```
