# Create SSM parameter for VPC ID
resource "aws_ssm_parameter" "vpc_id" {
  name  = "${local.ssm_vpc}/vpc_id"
  type  = "String"
  value = aws_vpc.main.id
  depends_on = [ aws_vpc.main ]
}

# SSM parameter for public subnet ID
resource "aws_ssm_parameter" "public_subnet_id" {
  name  = "${local.ssm_subnet_ids}/public_subnet_id"
  type  = "String"
  value = aws_subnet.public.id
}

# SSM parameter for private subnet ID
resource "aws_ssm_parameter" "private_subnet_id" {
  name  = "${local.ssm_subnet_ids}/private_subnet_id"
  type  = "String"
  value = aws_subnet.private.id
}

# SSM parameter for NAT ID
resource "aws_ssm_parameter" "ngw_id" {
  name  = "${local.ssm_gateway_ids}/nat_id"
  type  = "String"
  value = aws_nat_gateway.ngw.id
}

# SSM parameter for Elastic IP ID
resource "aws_ssm_parameter" "eip_id" {
  name  = "${local.ssm_gateway_ids}/eip_id"
  type  = "String"
  value = aws_eip.nat.id
}

# SSM parameter for storing the Internet Gateway ID
resource "aws_ssm_parameter" "igw_id" {
  name  = "${local.ssm_gateway_ids}/igw_id"
  type  = "String"
  value = aws_internet_gateway.igw.id
}

# Create SSM parameter to store Public Route Table ID
resource "aws_ssm_parameter" "public_rtb_id" {
  name  = "${local.ssm_sg_ids}/public-rtb_id"
  type  = "String"
  value = aws_route_table.public_rtb.id
}

# # Create SSM parameter to store Private Route Table ID
resource "aws_ssm_parameter" "private_rtb_id" {
  name  = "${local.ssm_rtb_ids}/private-rtb_id"
  type  = "String"
  value = aws_route_table.private_rtb.id
}