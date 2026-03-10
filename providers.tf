# ============================================================================
# Terraform and Provider Configuration
# ============================================================================

# Configure the AWS Provider with the region from the variables file
# This provider is used by all AWS resources in this configuration
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" 
    }
  }
}
provider "aws" {
  region = var.REGION
}