# Data source for Availability Zones
data "aws_availability_zones" "azs" {}

# Data source for AWS ACM certificate
data "aws_acm_certificate" "domain_cert" {
  domain = var.domain
  types = ["AMAZON_ISSUED"]
}

# Select existing VPC
data "aws_ssm_parameter" "vpc_id" {
    name = "${local.ssm_vpc}/vpc_id"
}

# Select Private subnets
data "aws_ssm_parameter" "private_subnet1" {
    name = "${local.ssm_subnet_ids}/private_subnet1_id"
}

data "aws_ssm_parameter" "private_subnet2" {
    name = "${local.ssm_subnet_ids}/private_subnet2_id"
}

# Select Public subnets
data "aws_ssm_parameter" "public_subnet1" {
  name = "${local.ssm_subnet_ids}/public_subnet1_id"
}

data "aws_ssm_parameter" "public_subnet2" {
  name = "${local.ssm_subnet_ids}/public_subnet2_id"
}