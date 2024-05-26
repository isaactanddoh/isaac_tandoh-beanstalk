module "vpc" {
  source                = "../../vpc"
  vpc_cidr              = var.vpc_cidr
  project               = var.project
  public_subnet1_cidr   = var.public_subnet1_cidr
  public_subnet2_cidr   = var.public_subnet2_cidr
  private_subnet1_cidr  = var.private_subnet1_cidr
  private_subnet2_cidr  = var.private_subnet2_cidr
  env = var.env
  domain = var.domain
}

# Beanstalk Environment
module "beanstalk_env" {
  source     = "../../beanstalk"
  env = var.env
  project = var.project
  domain = var.domain
  depends_on = [module.vpc]
}