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
  source              = "../modules/aws/route_table"
  env                 = local.env
  vpc_id              = module.vpc.id_cloud_pratica
  internet_gateway_id = module.internet_gateway.id_cloud_pratica
  public_subnet_ids   = local.public_subnet_ids
}
