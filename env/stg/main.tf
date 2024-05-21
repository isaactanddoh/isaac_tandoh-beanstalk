module "vpc" {
    source = "../../vpc"
    vpc_cidr = var.vpc_cidr
    project = var.project
    public_subnet_cidr = var.public_subnet_cidr
    private_subnet_cidr = var.private_subnet_cidr
    env = var.env
}

module "beanstalk_env" {
  source     = "../../beanstalk"
  env = var.env
  project = var.project
  domain = var.domain
  depends_on = [module.vpc]
}