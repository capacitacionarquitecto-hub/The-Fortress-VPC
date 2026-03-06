# ============================================================================
# Terraform and Provider Configuration
# ============================================================================

# Configure the AWS Provider with the region from the variables file
# This provider is used by all AWS resources in this configuration
provider "aws" {
  region = var.REGION
}