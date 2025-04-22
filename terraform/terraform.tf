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