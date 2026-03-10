# ============================================================================
# Variable Definitions - Configuration inputs for the Fortress VPC
# ============================================================================

# Cloud provider selection (currently configured for AWS only)
variable "PROVIDER" {
  description = "The cloud provider to use (e.g., aws, azure, google)"
  type        = string
  default     = "aws"
}

# AWS Region where the VPC infrastructure will be deployed
# Default: us-east-1 (N. Virginia)
variable "REGION" {
  description = "The AWS region to deploy the VPC infrastructure in"
  type        = string
  default     = "us-east-1"
}

# CIDR block for the entire VPC network
# This defines the IP address range for all resources within the VPC
# Default: 10.0.0.0/16 (65,536 available IP addresses)
variable "VPC_CIDR" {
  description = "The CIDR block for the VPC (format: X.X.X.X/16)"
  type        = string
  default     = "10.0.0.0/16"
}

# Project name used for tagging and naming all resources
# This helps with resource organization, cost allocation, and identification
variable "PROJECT_NAME" {
  description = "The name of the project - used for resource naming and tagging"
  type        = string
  default     = "fortress-vpc"
}	