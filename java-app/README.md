# Spring Boot + OpenTelemetry Demo

This is a simple Spring Boot application instrumented with OpenTelemetry Java agent.

## Prerequisites

- Docker and Docker Compose
- Kubernetes cluster with OpenTelemetry collector deployed
- Port forwarding setup for the OTel collector (using ../setup-port-forward.sh)

## Running the Application

1. Make sure your Kubernetes port-forwarding is active:
   ```bash
   # In a separate terminal window
   ../setup-port-forward.sh
   ```

2. Build and run the containerized application:
   ```bash
   ./run.sh
   ```
   
   Or manually:
   ```bash
   docker-compose up --build
   ```

## Testing the Application

Access the application at:
- Application endpoint: http://localhost:8080
- Actuator endpoints: http://localhost:8080/actuator
- Prometheus metrics: http://localhost:8080/actuator/prometheus

Send a request to generate some telemetry:
```bash
curl http://localhost:8080/hello/world
```

## Viewing Telemetry Data

After running the application and sending requests, you can view:

- Traces in Jaeger UI: http://localhost:16686
- Metrics in Prometheus: http://localhost:9090
- Dashboards in Grafana: http://localhost:3000

## How It Works

1. The Spring Boot application is instrumented with the OpenTelemetry Java agent
2. The agent automatically captures HTTP requests, database queries, and more
3. Telemetry data is sent to the Kubernetes OTel collector over OTLP gRPC
4. The collector processes and routes the data to appropriate backends 