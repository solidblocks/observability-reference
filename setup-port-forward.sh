#!/bin/bash
set -e

# Function to clean up background processes on exit
cleanup() {
  echo "Stopping port forwarding..."
  # Kill all background processes
  kill $(jobs -p) 2>/dev/null || true
  echo "Port forwarding stopped."
  exit 0
}

# Set up the cleanup trap
trap cleanup EXIT INT TERM

echo "Setting up port forwarding..."
echo "Grafana will be available at http://localhost:3000"
echo "Prometheus will be available at http://localhost:9090"
echo "Alertmanager will be available at http://localhost:9093"
echo "Karpor UI will be available at https://localhost:7443"
echo "Press Ctrl+C to stop port forwarding"

# Start port forwarding
kubectl -n monitoring port-forward svc/prometheus-grafana 3000:80 &
GRAFANA_PID=$!
echo "Grafana port forwarding started (PID: $GRAFANA_PID)"

kubectl -n monitoring port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 &
PROMETHEUS_PID=$!
echo "Prometheus port forwarding started (PID: $PROMETHEUS_PID)"

kubectl -n monitoring port-forward svc/prometheus-kube-prometheus-alertmanager 9093:9093 &
ALERTMANAGER_PID=$!
echo "Alertmanager port forwarding started (PID: $ALERTMANAGER_PID)"

kubectl -n backend-team port-forward service/backend-service 8080:8080 &
BACKEND_PID=$!
echo "Backend service port forwarding started (PID: $BACKEND_PID)"

kubectl -n karpor port-forward service/karpor-server 7443:7443 &
KARPOR_PID=$!
echo "Karpor UI port forwarding started (PID: $KARPOR_PID)"

echo "All port forwarding is active. Press Ctrl+C to terminate."

# Wait for all background processes
wait 