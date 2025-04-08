#!/bin/bash

# Basic script to send a test trace span using otel-cli via port-forward

# Check if otel-cli is installed
if ! command -v otel-cli &> /dev/null
then
    echo "Error: otel-cli command could not be found."
    echo "Please install it from: https://github.com/equinix-labs/otel-cli"
    exit 1
fi

# --- Configuration ---
# Assumes kubectl port-forward is running for svc/otel-collector-main-collector
ENDPOINT_GRPC="localhost:4317"
ENDPOINT_HTTP="http://localhost:4318" # otel-cli needs http:// prefix for http endpoints
SERVICE_NAME="my-local-app"
SPAN_NAME="test-span-from-script-$(date +%s)" # Add timestamp for uniqueness
ATTRS_GRPC="script.language=bash,user.id=$((1000 + RANDOM % 9000))"
ATTRS_HTTP="script.language=bash,request.method=GET"

# --- Send Span via gRPC (default) ---
echo "Attempting to send span via gRPC to ${ENDPOINT_GRPC}..."

# Send the span using flags directly
otel-cli span \
  --endpoint "${ENDPOINT_GRPC}" \
  --insecure \
  --service "${SERVICE_NAME}" \
  --name "${SPAN_NAME}_grpc" \
  --kind "client" \
  --attrs "${ATTRS_GRPC}" \
  --tp-print # Optional: print traceparent

if [ $? -eq 0 ]; then
  echo "Span sent via gRPC successfully."
else
  echo "Failed to send span via gRPC."
fi

echo # Newline for separation

# --- Send Span via HTTP/protobuf ---
echo "Attempting to send span via HTTP/protobuf to ${ENDPOINT_HTTP}..."

# Send the span using flags directly
otel-cli span \
  --protocol http/protobuf \
  --endpoint "${ENDPOINT_HTTP}" \
  --service "${SERVICE_NAME}" \
  --name "${SPAN_NAME}_http" \
  --kind "server" \
  --attrs "${ATTRS_HTTP}"

if [ $? -eq 0 ]; then
  echo "Span sent via HTTP/protobuf successfully."
else
  echo "Failed to send span via HTTP/protobuf."
fi

echo
echo "Check the collector logs in the 'monitoring' namespace to see the received spans."