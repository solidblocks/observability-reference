# AWS X-Ray Datasource for Grafana

This document provides information on how to set up and configure the AWS X-Ray datasource in Grafana using a Kubernetes secret managed by Terraform.

## Prerequisites

- AWS X-Ray data source plugin must be installed in Grafana (`grafana-x-ray-datasource`).
- IAM Role (`GrafanaXRayReaderRole`) with `AWSXrayReadOnlyAccess` policy attached.
- IAM User (`grafana-xray-assumer-user`) with permission to assume the reader role and its access keys.

## Configuration

The X-Ray datasource in Grafana is configured via a Kubernetes secret:

1. **Plugin Installation**
   - The plugin `grafana-x-ray-datasource` is installed automatically through the Helm chart configuration in `values/prometheus-values.yaml`.

2. **Datasource Secret**
   - Terraform creates a Kubernetes secret named `grafana-xray-datasource` in the `monitoring` namespace.
   - This secret contains the *complete* datasource configuration, including the `assumeRoleArn`, `defaultRegion`, `accessKey`, and `secretKey`.
   - The secret is labeled with `grafana_datasource: "1"`.

3. **Grafana Sidecar**
   - The Grafana Helm chart is configured with `sidecar.datasources.enabled: true`.
   - The sidecar watches for secrets in the `monitoring` namespace with the label `grafana_datasource: "1"` and automatically provisions them as datasources in Grafana.

## Setup Instructions

1. **Apply Terraform Resources**
   ```bash
   cd terraform
   terraform apply
   ```
   This creates the necessary IAM resources (role, user, keys, policy attachments) and the `grafana-xray-datasource` Kubernetes secret.

2. **Apply Helmfile Configuration**
   ```bash
   helmfile apply
   ```
   This installs/upgrades the Prometheus stack, including Grafana with the sidecar enabled and the X-Ray plugin.

## Verification

To verify the X-Ray datasource is working correctly:

1. Log in to Grafana.
2. Go to Configuration > Data sources.
3. You should see the `X-Ray` datasource listed (it might take a minute for the sidecar to provision it).
4. Click on the `X-Ray` datasource.
5. Click the "Test" button to verify the connection.

## Troubleshooting

If you encounter issues:

1. **Check IAM Permissions**: Ensure the `grafana-xray-assumer-user` exists, has the `AssumeGrafanaXRayReaderRole` policy attached, and has valid access keys.
2. **Check Role Permissions**: Verify the `GrafanaXRayReaderRole` exists and has the `AWSXrayReadOnlyAccess` policy attached.
3. **Check Datasource Secret**: Verify the secret `grafana-xray-datasource` exists in the `monitoring` namespace and contains the correct configuration and credentials.
   ```bash
   kubectl -n monitoring get secret grafana-xray-datasource -o yaml
   # Decode the datasource.yaml field if needed
   ```
4. **Check Grafana Pod Logs**: Look for errors related to the datasource sidecar or the X-Ray plugin.
   ```bash
   kubectl -n monitoring logs -l app.kubernetes.io/name=grafana
   # Look for logs from the sidecar container as well
   kubectl -n monitoring logs -l app.kubernetes.io/name=grafana -c grafana-sc-datasources
   ```
5. **Region Setting**: Ensure the `defaultRegion` in the datasource secret matches where your X-Ray traces are stored.

## Manual Configuration (Not Recommended)

Manual configuration is generally not needed with this setup. If you need to inspect the configuration Grafana is using, you can view the secret content:

```bash
kubectl -n monitoring get secret grafana-xray-datasource -o jsonpath='{.data.datasource\.yaml}' | base64 --decode
``` 