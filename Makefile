.PHONY: setup apply destroy clean debug-cluster setup-tools port-forward test-otel list-images generate-traces tf-apply tf-plan tf-destroy

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

tf-apply:
	@echo "Applying Terraform configuration in ./terraform..."
	cd terraform && terraform init
	cd terraform && terraform apply

tf-plan:
	@echo "Plan Terraform configuration in ./terraform..."
	cd terraform && terraform apply

tf-destroy:
	@echo "Destroying Terraform resources in ./terraform..."
	cd terraform && terraform destroy

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
	@echo "  test-otel    - Send test OTLP data using otel-cli via port-forward"
	@echo "  generate-traces - Generate traces using telemetrygen"
	@echo "  list-images  - List all unique container images running in the cluster"
	@echo "  tf-apply  - Apply Terraform configuration"
	@echo "  tf-destroy - Destroy Terraform resources"

debug-cluster:
	@echo "=== Colima Cluster Debug Info ==="
	@echo "\n=== Node Status ==="
	kubectl get nodes -o wide
	@echo "\n=== Node Resources ==="
	kubectl describe nodes | grep -A 5 "Allocated resources"
	@echo "\n=== Pods Status ==="
	kubectl get pods -A
	@echo "\n=== OTel Operator Version ==="
	@kubectl get pods -n opentelemetry-operator-system -l app.kubernetes.io/name=opentelemetry-operator -o jsonpath='{.items[0].spec.containers[0].image}' | sed 's/.*://' | xargs -I {} echo "Operator Image Tag: {}" || echo "Operator pod not found or image tag unavailable."
	@echo "\n=== OTel Collector Version ==="
	@kubectl get pods -n monitoring -l app.kubernetes.io/managed-by=opentelemetry-operator -o jsonpath='{.items[0].spec.containers[0].image}' | sed 's/.*://' | xargs -I {} echo "Collector Image Tag: {}" || echo "Collector pod not found or image tag unavailable."
	@echo "\n=== Recent Events ==="
	kubectl get events --sort-by='.lastTimestamp' -A | tail -n 20
	@echo "\n=== Colima Status ==="
	colima status

port-forward:
	@echo "Starting port forwarding..."
	@chmod +x setup-port-forward.sh
	./setup-port-forward.sh

test-otel:
	@echo "Sending test OTLP data via otel-cli..."
	@echo "Ensure port-forward is running in another terminal (make port-forward)"
	@chmod +x scripts/send-otel-test.sh
	./scripts/send-otel-test.sh
	@echo "\nFetching recent collector logs (expecting to see the spans above)..."
	@kubectl logs -n monitoring -l app.kubernetes.io/managed-by=opentelemetry-operator --tail 20 || echo "Could not fetch collector logs. Is the collector running?"

generate-traces:
	@echo "Generating traces using telemetrygen..."
	@echo "Ensure port-forward is running in another terminal (make port-forward)"
	telemetrygen traces --otlp-insecure --traces 3
	@echo "\nFetching recent collector logs (expecting to see the spans)..."
	@kubectl logs -n monitoring -l app.kubernetes.io/managed-by=opentelemetry-operator --tail 20 || echo "Could not fetch collector logs. Is the collector running?"

list-images:
	@echo "Listing unique container images running in the cluster..."
	@kubectl get pods -A -o jsonpath='{range .items[*]}{.spec.containers[*].image}{"\n"}{end}' | sort | uniq