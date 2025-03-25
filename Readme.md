# Prometheus Stack on Kubernetes with Helmfile

This project deploys the Prometheus Stack (kube-prometheus-stack) using Helmfile on a Kubernetes cluster.

## Prerequisites

- Kubernetes cluster (e.g., Colima with Kubernetes enabled)
- kubectl
- helm
- helmfile
- helm-diff plugin

## Setup

```
make setup
```

## Deployment

```bash
# Deploy Prometheus Stack
make apply
```

## Accessing the Services

```bash
# Start port forwarding to access the services
make port-forward
```

This will make the following services available:
- Grafana: http://localhost:3000 (username: admin, password: admin)
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093

Press Ctrl+C to stop port forwarding.

## Debugging

```bash
# Show detailed information about your cluster
make debug-cluster
```

## Cleaning Up

```bash
# Delete the deployed services
helmfile destroy
```

## Configuration

- `helmfile.yaml`: Main configuration file for Helmfile
- `values/prometheus-values.yaml`: Values for Prometheus Stack Helm chart

## Troubleshooting

1. If services do not start, check pod status:
   ```bash
   kubectl get pods -n monitoring
   kubectl describe pod [pod-name] -n monitoring
   ```

2. Check events:
   ```bash
   kubectl get events -n monitoring
   ```

3. Check logs:
   ```bash
   kubectl logs [pod-name] -n monitoring
   ```
