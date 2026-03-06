variable "PROVIDER" {
  description = "The cloud provider to use (e.g., aws, azure, google)"
  type        = string
  default     = "aws"
}

variable "REGION" {
  description = "The region to deploy the VPC in"
  type        = string
  default     = "us-east-1"
}

variable "VPC_CIDR" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "PROJECT_NAME" {
  description = "The name of the project"
  type        = string
  default     = "fortress-vpc"
}	