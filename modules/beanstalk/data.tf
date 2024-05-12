# Data source for Availability Zones
data "aws_availability_zones" "azs" {}

# Data source for AWS ACM certificate
data "aws_acm_certificate" "domain_cert" {
  domain   = var.domain
  arn = var.certificate_arn
  statuses = ["ISSUED"]
}

# Select existing VPC
data "aws_ssm_parameter" "vpc_id" {
    name = "/isaac-beanstalk-test/vpc/vpc_id"
}

# Select Private subnets
data "aws_ssm_parameter" "private_subnet" {
    name = "/isaac-beanstalk-test/subnets/private_subnet_id"
}

# Select Public subnets
data "aws_ssm_parameter" "public_subnet" {
  name = "/isaac-beanstalk-test/subnets/public_subnet_id"
}