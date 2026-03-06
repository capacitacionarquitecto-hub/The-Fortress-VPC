resource "aws_vpc" "main" {
  cidr_block = var.VPC_CIDR
  enable_dns_hostnames = true
  enable_dns_support   = true   

  tags = {
    Name = var.PROJECT_NAME
  }
}