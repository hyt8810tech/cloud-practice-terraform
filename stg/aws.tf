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

module "ecr" {
  source = "../modules/aws/ecr"
  env    = local.env
}

module "secrets_manager" {
  source = "../modules/aws/secrets_manager"
  env    = local.env
}

module "sqs" {
  source     = "../modules/aws/sqs"
  env        = local.env
  account_id = local.account_id
}

module "ses" {
  source = "../modules/aws/ses"
  env    = local.env
  cloud_pratica = {
    domain = local.base_host
  }
}

module "iam_role" {
  source = "../modules/aws/iam_role"
  env    = local.env
}

module "ec2" {
  source           = "../modules/aws/ec2"
  env              = local.env
  public_subnet_id = module.subnet.id_public_subnet_1a
  bastion = {
    iam_instance_profile = module.iam_role.name_cp_bastion
    security_group_id    = module.security_group.id_bastion
  }
  nat_1a = {
    iam_instance_profile = module.iam_role.name_cp_nat
    security_group_id    = module.security_group.id_nat
  }
}

module "rds_cp" {
  env                = local.env
  source             = "../modules/aws/rds_unit"
  identifier         = "cloud-pratica-${local.env}"
  db_name            = "slack_metrics"
  engine_version     = "16.8"
  instance_class     = "db.t3.micro"
  security_group_ids = [module.security_group.id_db]
  private_subnet_ids = local.private_subnet_ids
  subnet_group_name = "cp-db-subnet-group-${local.env}"
  family = "postgres16"
  parameter_group_name = "cp-db-parameter-group-${local.env}"
}

module "acm_cloud_pratica_com_ap_northeast_1" {
  source = "../modules/aws/acm_unit"
  domain_name = "*.${local.base_host}"
  providers = {
    aws = aws
  }
}

module "acm_cloud_pratica_com_us_east_1" {
  source = "../modules/aws/acm_unit"
  domain_name = "*.${local.base_host}"
  providers = {
    aws = aws.us_east_1
  }
}
