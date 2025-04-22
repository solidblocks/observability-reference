# --- Grafana X-Ray Read-Only Access ---

# 1. IAM Policy for Grafana Read-Only Access to X-Ray
# --- Removed: Using AWS managed policy 'AWSXRayReadOnlyAccess' instead ---
# resource "aws_iam_policy" "grafana_xray_read_policy" { ... }

# 2. IAM Role for Grafana to Assume
#    NOTE: Updated assume_role_policy to trust the dedicated grafana_assumer_user.
resource "aws_iam_role" "grafana_xray_reader_role" {
  name = "GrafanaXRayReaderRole"

  # Trust policy allowing ONLY the grafana_assumer_user to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_user.grafana_assumer_user.arn
        },
        Action = "sts:AssumeRole",
        # Optional: Add conditions like MFA or External ID if required
      }
    ]
  })

  tags = {
    Purpose = "grafana-xray-reader-role"
  }
}

# 3. Attach the read-only policy to the Grafana reader role
resource "aws_iam_role_policy_attachment" "grafana_xray_read_policy_attachment" {
  role       = aws_iam_role.grafana_xray_reader_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"
}

# --- Grafana Assumer User and Credentials ---

# 4. IAM User that Grafana will use to assume the reader role
resource "aws_iam_user" "grafana_assumer_user" {
  name = "grafana-xray-assumer-user"
  path = "/service/"

  tags = {
    Purpose = "grafana-assume-xray-role-user"
  }
}

# 5. Policy allowing ONLY assuming the specific Grafana reader role
resource "aws_iam_policy" "assume_grafana_reader_role_policy" {
  name        = "AssumeGrafanaXRayReaderRole"
  description = "Allow assuming the GrafanaXRayReaderRole"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = aws_iam_role.grafana_xray_reader_role.arn # Restrict to only this role
      }
    ]
  })
}

# 6. Attach the AssumeRole policy to the Grafana assumer user
resource "aws_iam_user_policy_attachment" "grafana_assume_role_attachment" {
  user       = aws_iam_user.grafana_assumer_user.name
  policy_arn = aws_iam_policy.assume_grafana_reader_role_policy.arn
}

# 7. Create Access Key for the Grafana assumer IAM user
#    WARNING: Handle these keys securely.
resource "aws_iam_access_key" "grafana_user_key" {
  user = aws_iam_user.grafana_assumer_user.name
}

# 9. Create a Kubernetes secret with the complete datasource configuration
resource "kubernetes_secret" "grafana_xray_datasource" {
  metadata {
    name = "grafana-xray-datasource"
    namespace = "monitoring"
    labels = {
      grafana_datasource = "1" # This label tells Grafana to load this as a datasource
    }
  }

  data = {
    # Entire datasource configuration in JSON format
    "datasource.yaml" = <<-EOT
apiVersion: 1
datasources:
- name: X-Ray
  type: grafana-x-ray-datasource
  access: proxy
  isDefault: false
  jsonData:
    authType: keys
    assumeRoleArn: ${aws_iam_role.grafana_xray_reader_role.arn}
    defaultRegion: eu-west-1
  secureJsonData:
    accessKey: ${aws_iam_access_key.grafana_user_key.id}
    secretKey: ${aws_iam_access_key.grafana_user_key.secret}
  version: 1
  editable: true
EOT
  }

  type = "Opaque"
}

# --- Outputs --- # Duplicated for now, will remove from aws-xray.tf next

output "grafana_reader_role_arn" {
  description = "ARN of the IAM role Grafana should assume for X-Ray read access."
  value       = aws_iam_role.grafana_xray_reader_role.arn
}

output "grafana_assumer_user_access_key_id" {
  description = "Access Key ID for the Grafana Assumer IAM user."
  value       = aws_iam_access_key.grafana_user_key.id
  sensitive   = true # Mark as sensitive, but still potentially logged by Terraform
}

output "grafana_assumer_user_secret_access_key" {
  description = "Secret Access Key for the Grafana Assumer IAM user. Handle with extreme care!"
  value       = aws_iam_access_key.grafana_user_key.secret
  sensitive   = true
} 