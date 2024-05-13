# Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "app" {
  name = "${local.name}-DotNetApp"
}

# Elastic Beanstalk environment
resource "aws_elastic_beanstalk_environment" "app-environment" {
  name                = "${local.name}-DotNetEnvironment"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2023 v3.0.6 running .NET 6"
  cname_prefix        = "${local.name}-dotnet-app"

  # VPC configuration
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_ssm_parameter.vpc_id.value
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", [data.aws_ssm_parameter.public_subnet.value, data.aws_ssm_parameter.private_subnet.value])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = data.aws_ssm_parameter.public_subnet.value
  }

  # Load balancer configuration
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "DefaultProcess"
    value     = "default"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = data.aws_acm_certificate.domain_cert.arn
  }

  # Instance type configuration
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.instance_profile.name
  }

    setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  # HTTPS Redirection
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "ListenerEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "ProtocolHttps"
    value     = "true"
  }
}

# IAM Role
resource "aws_iam_role" "iam_role" {
  name = "${local.name}-IAMRole"

  assume_role_policy = file("${path.module}/templates/role.json")
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${local.name}-instance-profile"

  role = aws_iam_role.iam_role.name
}


# Attach policies to IAM Role
resource "aws_iam_role_policy_attachment" "my_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"

}