# Java Application with OpenTelemetry

This is a simple Java application instrumented with OpenTelemetry.

## Prerequisites

- Docker and Docker Compose
- OpenTelemetry Collector accessible on port 4318

## Running the Application

There are two ways to run the application:

### 1. Standard Setup (requires external OpenTelemetry Collector)

```bash
make start
```

This will build and start the application container. The application will be available on port 18080.

### 2. Complete Local Setup (includes Jaeger and OpenTelemetry Collector)

```bash
make start-local
```

This will start:
- The Java application on port 18080
- Jaeger UI accessible at http://localhost:16686
- OpenTelemetry Collector on port 4318

## OpenTelemetry Configuration

The application requires an OpenTelemetry collector to be running and accessible on port 4318. It exports traces via OTLP protocol to this endpoint.

## Testing the Application

Access the application at:
- Application endpoint: http://localhost:18080
- Actuator endpoints: http://localhost:18080/actuator
- Prometheus metrics: http://localhost:18080/actuator/metrics

Send a request to generate some telemetry:
```bash
curl http://localhost:18080/hello/world
```

## Viewing Traces

After running the application with the local setup and sending requests, you can view traces in the Jaeger UI at http://localhost:16686.
