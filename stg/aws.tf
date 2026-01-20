module "vpc" {
  source = "../modules/aws/vpc"
  env    = "stg"
}

module "subnet" {
  source = "../modules/aws/subnet"
  env    = "stg"
  vpc_id = module.vpc.id_cloud_pratica
}

module "internet_gateway" {
  source = "../modules/aws/internet_gateway"
  env    = "stg"
  vpc_id = module.vpc.id_cloud_pratica
}

module "route_table" {
  source                   = "../modules/aws/route_table"
  env                      = local.env
  vpc_id                   = module.vpc.id_cloud_pratica
  internet_gateway_id      = module.internet_gateway.id_cloud_pratica
  public_subnet_ids        = local.public_subnet_ids
  private_subnet_ids       = local.private_subnet_ids
  nat_network_interface_id = "eni-0f31ccb6c490220e6"
}

module "security_group" {
  source                     = "../modules/aws/security_group"
  env                        = local.env
  vpc_id                     = module.vpc.id_cloud_pratica
  private_subnet_cidr_blocks = local.private_subnet_cidr_blocks
}

import {
  to = module.security_group.aws_security_group.db
  id = "sg-0c569a89c11809558"
}

import {
  to = module.security_group.aws_vpc_security_group_ingress_rule.db["sg-05ca7923174fca8bd"]
  id = "sgr-06189bd20ed65c2ca"
}

import {
  to = module.security_group.aws_vpc_security_group_ingress_rule.db["sg-035a21160a660e166"]
  id = "sgr-01b7b0e33e1fca36d"
}

import {
  to = module.security_group.aws_vpc_security_group_ingress_rule.db["sg-06ee78a27a605e60a"]
  id = "sgr-0123398cab2e8fddd"
}

import {
  to = module.security_group.aws_vpc_security_group_egress_rule.db
  id = "sgr-0e6451aaaadcfda0d"
}








