# Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "app" {
  name = "${local.name}-DotNetApp"
}

# Elastic Beanstalk environment
resource "aws_elastic_beanstalk_environment" "app-environment" {
  name                = "${local.name}-DotNetEnvironment"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Windows Server 2022 v2.15.1 running IIS 10.0"
  cname_prefix        = "${local.name}-dotnet-app"


  # VPC configuration
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_ssm_parameter.vpc_id.value
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  # Load balancer configuration
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", [data.aws_ssm_parameter.public_subnet1.value, data.aws_ssm_parameter.public_subnet2.value, data.aws_ssm_parameter.private_subnet1.value, data.aws_ssm_parameter.private_subnet2.value, ])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", [data.aws_ssm_parameter.public_subnet1.value, data.aws_ssm_parameter.public_subnet2.value])
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "ListenerProtocol:443"
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
    namespace = "aws:elbv2:listener:80"
    name      = "ListenerEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elbv2:listener:80"
    name      = "ListenerProtocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elbv2:listener:80"
    name      = "DefaultProcess"
    value     = "default"
  }

  setting {
    namespace = "aws:elbv2:listener:80"
    name      = "ForwardedProtocol"
    value     = "HTTPS"
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

  # Autoscaling configuration
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
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "Health"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:healthcheck"
    name      = "HealthCheckPath"
    value     = "/"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:healthcheck"
    name      = "HealthCheckInterval"
    value     = "30"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:healthcheck"
    name      = "HealthCheckTimeout"
    value     = "5"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:healthcheck"
    name      = "HealthyThreshold"
    value     = "2"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:healthcheck"
    name      = "UnhealthyThreshold"
    value     = "5"
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