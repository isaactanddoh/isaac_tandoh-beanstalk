locals {
  name            = format("%s-%s-%s", "isaac", var.project, var.env)
  ssm_vpc         = format("/%s/%s", local.name, "vpc")
  ssm_subnet_ids  = format("/%s/%s", local.name, "subnets")
  ssm_gateway_ids = format("/%s/%s", local.name, "gateway_ids")
  ssm_sg_ids      = format("/%s/%s", local.name, "sg_ids")
  ssm_rtb_ids     = format("/%s/%s", local.name, "rtb_ids")
  ssm_vpc_sg_id   = format("/%s/%s", local.name, "vpc_sg")
}