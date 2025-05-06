# Java Application Tracing Setup with Jaeger

This document outlines the configuration that enables the `java-app` to send traces to Jaeger via the OpenTelemetry Collector.

## Overview

The tracing setup involves three main components:

1.  **Java Application (`java-app`)**: Instrumented with the OpenTelemetry Java agent to automatically generate and export traces.
2.  **OpenTelemetry Collector (`otel-collector`)**: Receives traces from the `java-app` and processes/exports them to Jaeger.
3.  **Jaeger (`jaeger`)**: Stores and visualizes the traces.

## Configuration Details

### 1. Java Application (`java-app`)

The `java-app` service in the `docker-compose-local.yml` file is configured with the following relevant environment variables for OpenTelemetry:

-   `OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318`: This tells the OpenTelemetry Java agent within the `java-app` to send traces to the `otel-collector` service at port `4318` using the OTLP HTTP protocol.
-   `OTEL_SERVICE_NAME=demo-service`: Sets the service name that will appear in Jaeger.
-   `OTEL_TRACES_EXPORTER=otlp`: Specifies that the OTLP exporter should be used for traces.
-   `OTEL_METRICS_EXPORTER=none` and `OTEL_LOGS_EXPORTER=none`: Metrics and logs exporting are disabled in this configuration, focusing only on traces.

The `java-app` `depends_on` the `otel-collector` to ensure the collector is started before the application attempts to send traces.

### 2. OpenTelemetry Collector (`otel-collector`)

The `otel-collector` service is configured via `otel-collector-config.yaml` and its `docker-compose-local.yml` entry:

-   **Receivers**:
    -   In `otel-collector-config.yaml`, the `otlp` receiver is configured to listen on:
        -   `0.0.0.0:4318` for OTLP/HTTP (used by `java-app`).
        -   `0.0.0.0:4317` for OTLP/gRPC.
    -   The `docker-compose-local.yml` file maps these ports: `"4318:4318"` and `"4317:4317"`.

-   **Processors**:
    -   A `batch` processor is configured to batch traces before exporting, which can improve efficiency.

-   **Exporters**:
    -   The `otlp` exporter in `otel-collector-config.yaml` is configured with:
        -   `endpoint: jaeger:4317`: This directs the collector to send traces to the `jaeger` service at port `4317` (Jaeger's OTLP gRPC port by default in its image).
        -   `tls:
      insecure: true`: Disables TLS for this internal communication.
    -   A `debug` exporter is also configured for logging traces, which can be helpful for troubleshooting.

-   **Service Pipeline**:
    -   The `traces` pipeline is defined to use the `otlp` receiver, `batch` processor, and then export to both `otlp` (to Jaeger) and `debug` (to logs).

The `otel-collector` `depends_on` `jaeger` to ensure Jaeger is running before the collector attempts to forward traces.

### 3. Jaeger (`jaeger`)

The `jaeger` service (using `jaegertracing/all-in-one:1.45.0` image) is configured as follows in `docker-compose-local.yml`:

-   **Ports**:
    -   `"16686:16686"`: Exposes the Jaeger UI.
    -   The image itself exposes OTLP gRPC on port `4317` and OTLP HTTP on port `4318` by default. The `otel-collector` exports to `jaeger:4317`.
-   **Environment**:
    -   `COLLECTOR_OTLP_ENABLED=true`: This is an environment variable specific to the Jaeger all-in-one image, ensuring its OTLP receiver components are active. Note that while Jaeger itself can receive OTLP directly, in this setup, the `otel-collector` is the primary receiver from the application.

## Trace Flow Summary

1.  The `java-app`, via the OpenTelemetry Java agent, sends traces to `http://otel-collector:4318`.
2.  The `otel-collector` receives these traces on its OTLP/HTTP receiver.
3.  The `otel-collector` batches the traces and then exports them to `jaeger:4317` (OTLP/gRPC).
4.  `jaeger` receives the traces on its OTLP/gRPC endpoint.
5.  Traces can be viewed in the Jaeger UI at `http://localhost:16686`.

This setup provides a robust way to collect, process, and visualize traces from the Java application, leveraging the flexibility of the OpenTelemetry Collector. 

## Further Reading

For more detailed OpenTelemetry configuration options and examples, refer to the following resources:

-   OpenTelemetry Demo Ad Service (Java Example): [https://opentelemetry.io/docs/demo/services/ad/](https://opentelemetry.io/docs/demo/services/ad/)
-   OpenTelemetry Java SDK Configuration: [https://opentelemetry.io/docs/languages/java/sdk/](https://opentelemetry.io/docs/languages/java/sdk/) 