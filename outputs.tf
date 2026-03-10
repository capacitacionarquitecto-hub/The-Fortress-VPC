# ============================================================================
# Output Values - Information exported after Terraform apply completes
# ============================================================================
# These outputs are displayed in the console and can be used by other
# Terraform configurations or scripts for further automation and integration

# ============================================================================
# VPC Outputs
# ============================================================================

# Output the ID of the main VPC resource
# This ID is required for associating other AWS resources with the VPC
output "vpc_id" {
  description = "The ID of the VPC created by this configuration"
  value       = aws_vpc.main.id
}

# Output the CIDR block of the VPC for reference
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# ============================================================================
# Internet Gateway Outputs
# ============================================================================

# Output the ID of the Internet Gateway
# This ID is needed for security group rules and additional routing configurations
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# ============================================================================
# NAT Gateway Outputs
# ============================================================================

# Output the ID of the NAT Gateway
# This ID is needed for security group rules and additional routing configurations
output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

# Output the public IP address of the NAT Gateway's Elastic IP
# This IP address is used for outbound internet connections from private subnets
output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT Gateway's Elastic IP"
  value       = aws_eip.nat.public_ip
}

# ============================================================================
# Route Table Outputs
# ============================================================================

# Output the ID of the public route table
# This ID is useful for associating additional subnets or troubleshooting routing
output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

# Output the ID of the private route table
# This ID is useful for associating additional subnets or troubleshooting routing
output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}

# ============================================================================
# Public Subnet Outputs
# ============================================================================

# Output the ID of the first public subnet
output "public_subnet_01_id" {
  description = "The ID of the first public subnet (us-east-1a)"
  value       = aws_subnet.public_subnet_01.id
}

# Output the ID of the second public subnet
output "public_subnet_02_id" {
  description = "The ID of the second public subnet (us-east-1b)"
  value       = aws_subnet.public_subnet_02.id
}

# Output CIDR block of the first public subnet
output "public_subnet_01_cidr" {
  description = "The CIDR block of the first public subnet"
  value       = aws_subnet.public_subnet_01.cidr_block
}

# Output CIDR block of the second public subnet
output "public_subnet_02_cidr" {
  description = "The CIDR block of the second public subnet"
  value       = aws_subnet.public_subnet_02.cidr_block
}

# ============================================================================
# Private Subnet Outputs (Application Tier)
# ============================================================================

# Output the ID of the first private application subnet
output "private_subnet_app_01_id" {
  description = "The ID of the first private application subnet (us-east-1a)"
  value       = aws_subnet.private_subnet_01.id
}

# Output the ID of the second private application subnet
output "private_subnet_app_02_id" {
  description = "The ID of the second private application subnet (us-east-1b)"
  value       = aws_subnet.private_subnet_02.id
}

# Output CIDR block of the first private application subnet
output "private_subnet_app_01_cidr" {
  description = "The CIDR block of the first private application subnet"
  value       = aws_subnet.private_subnet_01.cidr_block
}

# Output CIDR block of the second private application subnet
output "private_subnet_app_02_cidr" {
  description = "The CIDR block of the second private application subnet"
  value       = aws_subnet.private_subnet_02.cidr_block
}

# ============================================================================
# Private Subnet Outputs (Database Tier)
# ============================================================================

# Output the ID of the first private database subnet
output "private_subnet_db_01_id" {
  description = "The ID of the first private database subnet (us-east-1a)"
  value       = aws_subnet.private_subnet_03.id
}

# Output the ID of the second private database subnet
output "private_subnet_db_02_id" {
  description = "The ID of the second private database subnet (us-east-1b)"
  value       = aws_subnet.private_subnet_04.id
}

# Output CIDR block of the first private database subnet
output "private_subnet_db_01_cidr" {
  description = "The CIDR block of the first private database subnet"
  value       = aws_subnet.private_subnet_03.cidr_block
}

# Output CIDR block of the second private database subnet
output "private_subnet_db_02_cidr" {
  description = "The CIDR block of the second private database subnet"
  value       = aws_subnet.private_subnet_04.cidr_block
}

# ============================================================================
# Summary Output - Complete VPC Architecture Report
# ============================================================================

# Consolidated output displaying the complete VPC network architecture
# This output provides a summary of all critical infrastructure identifiers
output "vpc_architecture_summary" {
  description = "Complete summary of the VPC architecture including all subnet information"
  value = {
    vpc_id                    = aws_vpc.main.id
    vpc_cidr                  = aws_vpc.main.cidr_block
    project_name              = var.PROJECT_NAME
    region                    = var.REGION
    internet_gateway_id       = aws_internet_gateway.main.id
    nat_gateway_id            = aws_nat_gateway.main.id
    nat_gateway_public_ip     = aws_eip.nat.public_ip
    public_route_table_id     = aws_route_table.public.id
    private_route_table_id    = aws_route_table.private.id
    public_subnets            = [aws_subnet.public_subnet_01.id, aws_subnet.public_subnet_02.id]
    private_app_subnets       = [aws_subnet.private_subnet_01.id, aws_subnet.private_subnet_02.id]
    private_database_subnets  = [aws_subnet.private_subnet_03.id, aws_subnet.private_subnet_04.id]
    public_cidrs              = [aws_subnet.public_subnet_01.cidr_block, aws_subnet.public_subnet_02.cidr_block]
    private_app_cidrs         = [aws_subnet.private_subnet_01.cidr_block, aws_subnet.private_subnet_02.cidr_block]
    private_database_cidrs    = [aws_subnet.private_subnet_03.cidr_block, aws_subnet.private_subnet_04.cidr_block]
  }
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer to access the app"
  value       = aws_lb.main.dns_name
}