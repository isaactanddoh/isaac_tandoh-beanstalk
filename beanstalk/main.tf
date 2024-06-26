# Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "app" {
  name = "${local.name}-DotNetApp"
}

# Elastic Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "app-environment" {
  name                = "${local.name}-DotNetEnvironment"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2023 v3.1.1 running .NET 8"
  cname_prefix        = "${local.name}-dotnet-app"

  # VPC Configuration
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_ssm_parameter.vpc_id.value
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "True"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  # Load Balancer Configuration
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "internet-facing"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", [data.aws_ssm_parameter.public_subnet1.value, data.aws_ssm_parameter.public_subnet2.value, data.aws_ssm_parameter.private_subnet1.value, data.aws_ssm_parameter.private_subnet2.value])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", [data.aws_ssm_parameter.public_subnet1.value, data.aws_ssm_parameter.public_subnet2.value])
  }

  # Listener Configuration
  setting {
    namespace = "aws:elbv2:listener:80"
    name      = "Protocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elbv2:listener:80"
    name      = "DefaultProcess"
    value     = "default"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = data.aws_acm_certificate.domain_cert.arn
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLPolicy"
    value     = "ELBSecurityPolicy-2016-08"
  }

  setting {
    namespace = "aws:elbv2:listener:default"
    name      = "ListenerEnabled"
    value     = "true"
  }

  # Instance Type Configuration
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

  # Autoscaling Configuration
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "2"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "4"
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
resource "aws_iam_role_policy_attachment" "role-attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}
