# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use a recent version of the AWS provider
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0" # Use a recent version of the Kubernetes provider
    }
  }
}

provider "aws" {
  # Configure your AWS provider as needed (e.g., region, profile)
  # region = "us-east-1" # Example region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
#    This will be attached to the role the user assumes.
resource "aws_iam_policy" "otel_collector_xray_write_policy" {
  name        = "OtelCollectorXRayWriteAccess"
  description = "IAM policy allowing sending traces to AWS X-Ray"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    Purpose = "otel-collector-xray-permissions"
  }
}

# 2. IAM User that will assume the role
#    This user's credentials will be used by the collector initially.
resource "aws_iam_user" "otel_collector_assumer_user" {
  name = "otel-collector-xray-assumer"
  path = "/service/"

  tags = {
    Purpose = "otel-collector-assume-role-user"
  }
}

# 3. IAM Role to be assumed
#    This role has the actual permissions to send data to X-Ray.
resource "aws_iam_role" "otel_collector_xray_target_role" {
  name = "otel-collector-xray-target-role"

  # Trust policy allowing the specific IAM user created above to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_user.otel_collector_assumer_user.arn
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Purpose = "otel-collector-xray-target-role"
  }
}

# 4. Attach the X-Ray write policy to the target role
resource "aws_iam_role_policy_attachment" "xray_write_policy_attachment" {
  role       = aws_iam_role.otel_collector_xray_target_role.name
  policy_arn = aws_iam_policy.otel_collector_xray_write_policy.arn
}

# 5. Policy allowing ONLY assuming the specific target role
#    This policy will be attached to the IAM user.
resource "aws_iam_policy" "assume_xray_target_role_policy" {
  name        = "AssumeOtelCollectorXRayTargetRole"
  description = "Allow assuming the otel-collector-xray-target-role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = aws_iam_role.otel_collector_xray_target_role.arn # Restrict to only this role
      }
    ]
  })
}

# 6. Attach the AssumeRole policy to the user
resource "aws_iam_user_policy_attachment" "assume_role_attachment" {
  user       = aws_iam_user.otel_collector_assumer_user.name
  policy_arn = aws_iam_policy.assume_xray_target_role_policy.arn
}

# 7. Create Access Key for the IAM user
#    WARNING: Storing and outputting secret keys from Terraform is not recommended
#             for production environments. Consider secure secret management.
resource "aws_iam_access_key" "otel_user_key" {
  user = aws_iam_user.otel_collector_assumer_user.name
}


# 8. Create a Kubernetes secret with the access key
resource "kubernetes_secret" "otel_aws_creds" {
  metadata {
    name = "otel-aws-creds"
    namespace = "monitoring"
  }
  data = {
    aws_access_key_id = aws_iam_access_key.otel_user_key.id
    aws_secret_access_key = aws_iam_access_key.otel_user_key.secret
    aws_region = "eu-west-1"
    target_role_arn = aws_iam_role.otel_collector_xray_target_role.arn
  }
}


# --- Outputs ---

output "target_role_arn" {
  description = "ARN of the IAM role the collector should assume."
  value       = aws_iam_role.otel_collector_xray_target_role.arn
}

output "assumer_user_access_key_id" {
  description = "Access Key ID for the IAM user. Use this for initial authentication."
  value       = aws_iam_access_key.otel_user_key.id
}

output "assumer_user_secret_access_key" {
  description = "Secret Access Key for the IAM user. Handle with extreme care!"
  value       = aws_iam_access_key.otel_user_key.secret
  sensitive   = true
}

output "xray_write_policy_arn" {
  description = "ARN of the created IAM policy for X-Ray write access (attached to the role)."
  value       = aws_iam_policy.otel_collector_xray_write_policy.arn
}
