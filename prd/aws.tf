module "vpc" {
  source = "../modules/aws/vpc"
  env    = local.env
}

module "subnet" {
  source = "../modules/aws/subnet"
  env    = local.env
  vpc_id = module.vpc.id_cloud_pratica
}

module "internet_gateway" {
  source = "../modules/aws/internet_gateway"
  env    = local.env
  vpc_id = module.vpc.id_cloud_pratica
}

module "route_table" {
  source                   = "../modules/aws/route_table"
  env                      = local.env
  vpc_id                   = module.vpc.id_cloud_pratica
  internet_gateway_id      = module.internet_gateway.id_cloud_pratica
  public_subnet_ids        = local.public_subnet_ids
  private_subnet_ids       = local.private_subnet_ids
  nat_network_interface_id = null
}

module "security_group" {
  source                     = "../modules/aws/security_group"
  env                        = local.env
  vpc_id                     = module.vpc.id_cloud_pratica
  private_subnet_cidr_blocks = local.private_subnet_cidr_blocks
}

module "route53_cloud_pratica_com" {
  source    = "../modules/aws/route53_unit"
  zone_name = local.base_host
  records   = []
}

module "iam_role" {
  source = "../modules/aws/iam_role"
  env    = local.env
}