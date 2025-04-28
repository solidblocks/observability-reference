# Provision AWS Managed Grafana using the module
# Documentation: https://registry.terraform.io/modules/terraform-aws-modules/managed-service-grafana/aws/latest

module "managed_grafana" {
  source  = "terraform-aws-modules/managed-service-grafana/aws"
  version = "~> 2.0" # Consider pinning to a specific minor version for stability

  name = "ntw-shadow-grafana" # Choose a unique name for your workspace

  # --- Required Configuration ---
  # REVIEW AND ADJUST these based on your AWS environment and security requirements
  account_access_type    = "CURRENT_ACCOUNT" # Or "ORGANIZATION"
  authentication_providers = ["AWS_SSO"]     # Or ["SAML"]
  permission_type        = "SERVICE_MANAGED" # Or "CUSTOMER_MANAGED"

  # --- Disable Enterprise License Association (for module v2.x) ---
  # Set to false if you don't have a Grafana Enterprise license/token
  associate_license = false

  # --- Enable X-Ray Data Source ---
  data_sources = ["XRAY", "CLOUDWATCH", "TIMESTREAM"]

  # --- Optional: VPC Configuration (if needed) ---
  # vpc_configuration = {
  #   security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"]
  #   subnet_ids         = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy"]
  # }

  # --- Optional: Role Association (needed for CUSTOMER_MANAGED permission_type) ---
  # role_arn = "arn:aws:iam::123456789012:role/MyGrafanaRole"

  # --- Optional: Grafana Configuration ---
  # grafana_version = "10.4" # Specify a Grafana version (check AWS supported versions)

  tags = {
    Environment = "dev"
    Project     = "ntw-shadow"
    ManagedBy   = "Terraform"
  }

  # --- Create an Admin API Key for Terraform --- #
  workspace_api_keys = {
    terraform-admin = {
      key_name        = "terraform-admin"
      key_role        = "ADMIN"
      seconds_to_live = 3600 # 1 hour, adjust as needed or omit for permanent
    }
  }
}

# --- Outputs ---

output "managed_grafana_endpoint" {
  description = "AWS Managed Grafana workspace endpoint"
  value       = module.managed_grafana.workspace_endpoint
}

output "managed_grafana_id" {
  description = "AWS Managed Grafana workspace ID"
  value       = module.managed_grafana.workspace_id
}

# Output the API key secret (sensitive)
output "managed_grafana_api_key_secret" {
  description = "API Key secret for Terraform to configure the Managed Grafana workspace"
  value       = try(module.managed_grafana.workspace_api_keys["terraform-admin"].key, null)
  sensitive   = true
} 