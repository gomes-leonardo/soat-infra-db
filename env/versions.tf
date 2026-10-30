terraform {
  required_version = ">= 1.10"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
    neon = {
      source  = "kislerdm/neon"
      version = "~> 0.18"
    }
  }

  # bucket e key por -backend-config: soat-infra-db/env/<env>/terraform.tfstate.
  backend "s3" {
    region       = "sa-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "kubernetes" {
  config_path    = pathexpand(var.kubeconfig_path)
  config_context = var.kube_context
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "soat"
      Repository  = "soat-infra-db"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Le NEON_API_KEY do ambiente. So e exigida quando db_backend = neon.
provider "neon" {}
