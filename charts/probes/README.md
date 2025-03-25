# Probes Helm Chart

This Helm chart defines Probe custom resources for monitoring external targets with Prometheus Blackbox Exporter.

## Purpose

The chart provides a structured way to define monitoring probes for external services using Prometheus's native Probe custom resource definition (CRD). This is a specialized resource type that integrates directly with the Prometheus Operator for blackbox-style monitoring.

## Usage

Add probes to the `values.yaml` file or override them using custom values files. Each probe will generate a Probe CRD to monitor the specified endpoint.

### Example values file

```yaml
probes:
  - name: grafana-website
    url: https://grafana.com
    module: https_2xx
    interval: 30s
    labels:
      app: blackbox-exporter
      category: website
    annotations:
      description: "Probe for Grafana website"

  - name: internal-service
    url: http://my-service.internal
    module: http_2xx
    interval: 15s
    enabled: true
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nameOverride` | Override the name of the chart | `""` |
| `fullnameOverride` | Override the full name of the chart | `""` |
| `probes` | List of probes to create | `[]` |
| `commonLabels` | Labels to apply to all resources | `{}` |

### Probe configuration

Each probe in the `probes` list can have the following parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `name` | Name of the probe (required) | `nil` |
| `url` | URL to probe (required) | `nil` |
| `module` | Blackbox exporter module to use | `http_2xx` |
| `interval` | Scrape interval | `30s` |
| `scrapeTimeout` | Scrape timeout | `15s` |
| `labels` | Additional labels | `{}` |
| `annotations` | Additional annotations | `{}` |
| `enabled` | Whether the probe is enabled | `true` |
| `metricRelabelings` | Additional metric relabelings | `[]` | 