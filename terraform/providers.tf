provider "aws" {
  # Configure your AWS provider as needed (e.g., region, profile)
  # region = "us-east-1" # Example region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
} 