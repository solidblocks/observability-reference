# Configure the Grafana provider to connect to the AWS Managed Grafana workspace
provider "grafana" {
  url  = "https://${module.managed_grafana.workspace_endpoint}"
  # Access the key directly from the module's output map
  auth = module.managed_grafana.workspace_api_keys["terraform-admin"].key
  # alias = "managed" # Use if you have multiple grafana provider instances
}

# Define the AWS X-Ray data source within Grafana
resource "grafana_data_source" "xray" {
  provider = grafana # Use if you set an alias above

  type = "grafana-x-ray-datasource"
  name = "AWS X-Ray (Terraform)" # Unique name for the data source in Grafana

  # Using "default" auth leverages the workspace IAM role (SERVICE_MANAGED permission type)
  json_data_encoded = jsonencode({
    authType      = "default"
    defaultRegion = "eu-west-2"
  })
}

# Install X-Ray plugin using the Grafana plugin API
resource "null_resource" "install_xray_plugin" {
  # This ensures it runs after the API key is created
  depends_on = [module.managed_grafana.workspace_api_keys]

  # Create a more secure method that doesn't store the token in state
  provisioner "local-exec" {
    # Pass the token as an environment variable instead of directly in the command
    environment = {
      GRAFANA_API_KEY = module.managed_grafana.workspace_api_keys["terraform-admin"].key
      GRAFANA_URL = "https://${module.managed_grafana.workspace_endpoint}"
    }
    
    # Use environment variables in the command instead of embedding values
    command = <<-EOT
      curl -X POST \
        -H "Authorization: Bearer $GRAFANA_API_KEY" \
        -H "Content-Type: application/json" \
        "$GRAFANA_URL/api/plugins/grafana-x-ray-datasource/install"
    EOT
  }
}
