# OpenTelemetry Collector Setup Summary

This document summarizes the steps taken to deploy the OpenTelemetry Operator and a basic Collector instance.

## 1. Prerequisites: cert-manager

- Added the `jetstack` Helm repository to `helmfile.yaml`.
- Installed `cert-manager` using its Helm chart (`jetstack/cert-manager`) via `helmfile.yaml`.
- Configured `installCRDs: true` initially, then adjusted to ensure CRDs were ready before dependent charts.
- Ensured `cert-manager` namespace (`cert-manager`) is created.
- Added `wait: true` to the `cert-manager` release in `helmfile.yaml`.

## 2. OpenTelemetry Operator Installation

- Added the `open-telemetry` Helm repository to `helmfile.yaml`.
- Added the `opentelemetry-operator` Helm release (`open-telemetry/opentelemetry-operator`) to `helmfile.yaml`.
- Created the operator namespace (`opentelemetry-operator-system`).
- Added a `needs` dependency in `helmfile.yaml` for the operator to wait for `cert-manager`.
- Added `wait: true` to the `otel-operator` release.
- Created `values/otel-operator-values.yaml` to specify the required `manager.collectorImage.repository` (e.g., `ghcr.io/open-telemetry/opentelemetry-collector/opentelemetry-collector`).
- Referenced this values file in the `otel-operator` release definition in `helmfile.yaml`.

## 3. OpenTelemetry Collector Instance Deployment

- Created `manifests/otel-collector.yaml` defining an `OpenTelemetryCollector` custom resource named `otel-collector-main` in the `monitoring` namespace.
- Configured the CR for `deployment` mode.
- Defined a basic pipeline in the CR's `spec.config`:
  - OTLP receiver (gRPC on 4317, HTTP on 4318)
  - Batch processor
  - Logging exporter (for debugging)
- Explicitly set `spec.image` in the CR (e.g., `otel/opentelemetry-collector-contrib:0.97.0`) to resolve an `ImagePullBackOff` error with the operator's default image.
- Initially configured a Helmfile `postsync` hook for the `otel-operator` release to `kubectl apply -f manifests/otel-collector.yaml`. (Note: Manual application was used during debugging, indicating the hook might need refinement or removal if manual application is preferred).

## 4. Verification

- Checked the status of the collector pod created by the operator using `kubectl get pods -n monitoring -l app.kubernetes.io/managed-by=opentelemetry-operator`.
- Described the pod (`kubectl describe pod ...`) to diagnose the `ImagePullBackOff` error.
- Checked the Kubernetes services created for the collector (`kubectl get svc -n monitoring -l app.kubernetes.io/managed-by=opentelemetry-operator`) to find the OTLP endpoints (e.g., `otel-collector-main-collector`).
- Inspected collector logs using `kubectl logs -n monitoring <pod-name> -f`.
- Used `kubectl port-forward svc/otel-collector-main-collector -n monitoring 4317:4317 4318:4318` to expose the collector ports locally.
- Created a test script `scripts/send-otel-test.sh` using `otel-cli` to send test spans via gRPC and HTTP to the port-forwarded endpoints.
- Confirmed receipt of test spans in the collector logs. 