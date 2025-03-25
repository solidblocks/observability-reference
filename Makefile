.PHONY: setup apply destroy clean debug-cluster setup-tools port-forward

setup-tools:
	@echo "Setting up required tools..."
	chmod +x setup-tools.sh
	./setup-tools.sh

setup: setup-tools
	@echo "Setting up Colima with Kubernetes..."
	colima start --cpu 4 --memory 8 --disk 50 --kubernetes

apply:
	@echo "Applying Prometheus Stack with helmfile..."
	helmfile apply

destroy:
	@echo "Helmfile destroy..."
	helmfile destroy

clean: destroy
	@echo "Cleaning up resources..."
	rm -rf .cache

validate:
	@echo "Validating helmfile..."
	helmfile lint

diff:
	@echo "Showing diff between current and desired state..."
	helmfile diff

help:
	@echo "Available commands:"
	@echo "  setup     - Start Colima with Kubernetes and set up environment"
	@echo "  apply     - Apply helmfile to deploy Prometheus stack"
	@echo "  validate  - Validate helmfile configuration"
	@echo "  diff      - Show diff between current and desired state"
	@echo "  destroy   - Stop Colima"
	@echo "  clean     - Clean up resources"
	@echo "  debug-cluster - Show detailed cluster information"
	@echo "  port-forward - Set up port forwarding for Grafana, Prometheus, and Alertmanager"

debug-cluster:
	@echo "=== Colima Cluster Debug Info ==="
	@echo "\n=== Node Status ==="
	kubectl get nodes -o wide
	@echo "\n=== Node Resources ==="
	kubectl describe nodes | grep -A 5 "Allocated resources"
	@echo "\n=== Pods Status ==="
	kubectl get pods -A
	@echo "\n=== Recent Events ==="
	kubectl get events --sort-by='.lastTimestamp' -A | tail -n 20
	@echo "\n=== Colima Status ==="
	colima status

port-forward:
	@echo "Starting port forwarding..."
	@chmod +x setup-port-forward.sh
	./setup-port-forward.sh