module "vpc" {
    source = "../modules/01-vpc"
    vpc_cidr = var.vpc_cidr
    project = var.project
    public_subnet_cidr = var.public_subnet_cidr
    private_subnet_cidr = var.private_subnet_cidr
    env = var.env
}

# Beanstalk Environment
module "beanstalk_env" {
  source = "../modules/02-beanstalk"
  depends_on = [ module.vpc ]
}