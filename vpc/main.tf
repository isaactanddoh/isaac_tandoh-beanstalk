# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name =  "${local.name}-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public1" {
  vpc_id                  = aws_ssm_parameter.vpc_id.value
  cidr_block              = var.public_subnet1_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name}-public-subnet-1"
  }
  availability_zone = data.aws_availability_zones.azs.names[0]
  depends_on        = [aws_vpc.main]
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_ssm_parameter.vpc_id.value
  cidr_block              = var.public_subnet2_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name}-public-subnet-2"
  }
  availability_zone = data.aws_availability_zones.azs.names[1]
  depends_on        = [aws_vpc.main]
}

# Private Subnets
resource "aws_subnet" "private1" {
  vpc_id                  = aws_ssm_parameter.vpc_id.value
  cidr_block              = var.private_subnet1_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name}-private-subnet-1"
  }
  availability_zone = data.aws_availability_zones.azs.names[0]
  depends_on        = [aws_vpc.main]
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_ssm_parameter.vpc_id.value
  cidr_block              = var.private_subnet2_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.name}-private-subnet-2"
  }
  availability_zone = data.aws_availability_zones.azs.names[1]
  depends_on        = [aws_vpc.main]
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_ssm_parameter.vpc_id.value
  tags = {
    Name = "${local.name}-IGW"
  }
  depends_on = [ aws_vpc.main ]
}

# Create EIP and NAT Gateway for private subnet

# EIP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${local.name}-EIP"
  }
}

# Associate the Elastic IP with the NAT gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_ssm_parameter.eip_id.value
  subnet_id    = aws_ssm_parameter.public_subnet1_id.value
  tags = {
    Name = "${local.name}-NAT-GW"
  }
  depends_on = [aws_internet_gateway.igw, aws_subnet.public1, aws_subnet.public2]
}

# Create a private route table
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_ssm_parameter.vpc_id.value

# Add a route to the NAT Gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_ssm_parameter.ngw_id.value
  }
  tags = {
    Name = "${local.name}-Private-RTB"
  }
  depends_on = [ aws_nat_gateway.ngw, aws_vpc.main, aws_subnet.private ]
}

# Route Table Association for the private subnet 1
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_ssm_parameter.private_subnet1_id.value
  route_table_id = aws_ssm_parameter.private_rtb_id.value
  depends_on = [ aws_route_table.private_rtb, aws_subnet.private]
}

# Route Table Association for the private subnet 2
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_ssm_parameter.private_subnet2_id.value
  route_table_id = aws_ssm_parameter.private_rtb_id.value
  depends_on = [ aws_route_table.private_rtb, aws_subnet.private]
}

# Create a Public RTB
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_ssm_parameter.vpc_id.value

  # Add a route to the Internet Gateway for Public Subnets
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_ssm_parameter.igw_id.value
  }
  tags = {
    Name = "${local.name}-Public-RTB"
  }
  depends_on = [ aws_internet_gateway.igw, aws_vpc.main, aws_subnet.public ]
}

# Route Table Association for the public subnet 1
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_ssm_parameter.public_subnet1_id.value
  route_table_id = aws_ssm_parameter.public_rtb_id.value
  depends_on = [ aws_route_table.public_rtb, aws_subnet.public ]
}

# Route Table Association for the public subnet 2
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_ssm_parameter.public_subnet2_id.value
  route_table_id = aws_ssm_parameter.public_rtb_id.value
  depends_on = [ aws_route_table.public_rtb, aws_subnet.public ]
}

# Create an Autoscaling Security Group
resource "aws_security_group" "vpc_sg" {
  name        = "${local.name}-sg"
  description = "Security group for vpc"
  vpc_id      = aws_ssm_parameter.vpc_id.value
  depends_on = [ aws_vpc.main ]

  tags = {
    Name = "${local.name}-SG"
  }

# Inbound Rule to accept incoming HTTP Traffic from the ALB Security Group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
  }

# Inbound Rule to accept incoming HTTPS Traffic from the ALB Security Group
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
        }

# Outbound Rule for all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
