# ============================================================================
# VPC Configuration - The Fortress Network Infrastructure
# ============================================================================

# Create the main VPC with DNS resolution enabled
resource "aws_vpc" "main" {
  cidr_block           = var.VPC_CIDR
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.PROJECT_NAME
  }
}

# ============================================================================
# Public Subnets - DMZ Layer for internet-facing resources
# ============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

# Public subnet in Availability Zone 1 (us-east-1a)
resource "aws_subnet" "public_subnet_01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.VPC_CIDR, 8, 1)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.PROJECT_NAME}-public-01"
    Type = "Public"
  }
}

# Public subnet in Availability Zone 2 (us-east-1b)
resource "aws_subnet" "public_subnet_02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.VPC_CIDR, 8, 2)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.PROJECT_NAME}-public-02"
    Type = "Public"
  }
}

# ============================================================================
# Private Subnets - Application Layer for secure application resources
# ============================================================================

# Private subnet 01 in Availability Zone 1 (Application tier)
resource "aws_subnet" "private_subnet_01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.VPC_CIDR, 8, 10)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.PROJECT_NAME}-private-01"
    Type = "Private"
    Tier = "Application"
  }
}

# Private subnet 02 in Availability Zone 2 (Application tier)
resource "aws_subnet" "private_subnet_02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.VPC_CIDR, 8, 11)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.PROJECT_NAME}-private-02"
    Type = "Private"
    Tier = "Application"
  }
}

# ============================================================================
# Private Subnets - Database Layer for secure database resources
# ============================================================================

# Private subnet 03 in Availability Zone 1 (Database tier)
resource "aws_subnet" "private_subnet_03" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.VPC_CIDR, 8, 20)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.PROJECT_NAME}-private-03"
    Type = "Private"
    Tier = "Database"
  }
}

# Private subnet 04 in Availability Zone 2 (Database tier)
resource "aws_subnet" "private_subnet_04" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.VPC_CIDR, 8, 21)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.PROJECT_NAME}-private-04"
    Type = "Private"
    Tier = "Database"
  }
}

# ============================================================================
# Internet Gateway - Gateway for public subnet internet connectivity
# ============================================================================

# Create the Internet Gateway to allow internet traffic to public subnets
# This resource enables bi-directional communication between the VPC and the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.PROJECT_NAME}-igw"
  }

  depends_on = [aws_vpc.main]
}

# ============================================================================
# Route Tables - Define routing rules for network traffic
# ============================================================================

# Create Route Table for public subnets with internet gateway route
# This table allows public subnets to route traffic destined for the internet 
# through the Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Default route: direct all outbound internet traffic to the Internet Gateway
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.PROJECT_NAME}-public-rt"
    Type = "Public"
  }

  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# Route Table Associations - Link route tables to subnets
# ============================================================================

# Associate the public route table with public subnet 01
# This enables resources in this subnet to access the internet via the IGW
resource "aws_route_table_association" "public_subnet_01" {
  subnet_id      = aws_subnet.public_subnet_01.id
  route_table_id = aws_route_table.public.id
}

# Associate the public route table with public subnet 02
# This enables resources in this subnet to access the internet via the IGW
resource "aws_route_table_association" "public_subnet_02" {
  subnet_id      = aws_subnet.public_subnet_02.id
  route_table_id = aws_route_table.public.id
}

# ============================================================================
# NAT Gateway - Enable outbound internet access for private subnets
# ============================================================================

# Allocate Elastic IP for the NAT Gateway
# This provides a static public IP address for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.PROJECT_NAME}-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]
}

# Create NAT Gateway in public subnet 01 for high availability
# NAT Gateway allows private subnet resources to initiate outbound connections to the internet
# while preventing inbound connections from the internet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_01.id

  tags = {
    Name = "${var.PROJECT_NAME}-nat-gw"
  }

  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# Private Route Tables - Routing for private subnets through NAT Gateway
# ============================================================================

# Create Route Table for private subnets with NAT Gateway route
# This table allows private subnets to route outbound internet traffic through the NAT Gateway
# while maintaining security by not allowing direct inbound internet access
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Default route: direct all outbound internet traffic to the NAT Gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.PROJECT_NAME}-private-rt"
    Type = "Private"
  }

  depends_on = [aws_nat_gateway.main]
}

# ============================================================================
# Private Route Table Associations - Link private route table to subnets
# ============================================================================

# Associate the private route table with private application subnet 01
# This enables resources in this subnet to access the internet via the NAT Gateway
resource "aws_route_table_association" "private_subnet_01" {
  subnet_id      = aws_subnet.private_subnet_01.id
  route_table_id = aws_route_table.private.id
}

# Associate the private route table with private application subnet 02
# This enables resources in this subnet to access the internet via the NAT Gateway
resource "aws_route_table_association" "private_subnet_02" {
  subnet_id      = aws_subnet.private_subnet_02.id
  route_table_id = aws_route_table.private.id
}

# Associate the private route table with private database subnet 01
# This enables resources in this subnet to access the internet via the NAT Gateway
resource "aws_route_table_association" "private_subnet_03" {
  subnet_id      = aws_subnet.private_subnet_03.id
  route_table_id = aws_route_table.private.id
}

# Associate the private route table with private database subnet 02
# This enables resources in this subnet to access the internet via the NAT Gateway
resource "aws_route_table_association" "private_subnet_04" {
  subnet_id      = aws_subnet.private_subnet_04.id
  route_table_id = aws_route_table.private.id
}

# ============================================================================
# Console Output - Print VPC Information to stdout
# ============================================================================

# Display VPC configuration details in the console for reference
resource "null_resource" "vpc_report" {
  provisioner "local-exec" {
    command = "echo 'VPC DEPLOYMENT REPORT' && echo '=====================' && echo 'VPC ID: ${aws_vpc.main.id}' && echo 'Project Name: ${var.PROJECT_NAME}' && echo 'CIDR Block: ${var.VPC_CIDR}' && echo 'Region: ${var.REGION}' && echo 'Internet Gateway ID: ${aws_internet_gateway.main.id}' && echo 'NAT Gateway ID: ${aws_nat_gateway.main.id}' && echo 'NAT Elastic IP: ${aws_eip.nat.public_ip}'"
  }

  depends_on = [aws_nat_gateway.main]
}