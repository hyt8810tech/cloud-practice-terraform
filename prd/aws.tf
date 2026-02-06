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
  nat_network_interface_id = module.ec2.network_interface_id_nat_1a
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
  records = [{
    name   = module.acm_cloud_pratica_com_ap_northeast_1.validation_record_name
    values = [module.acm_cloud_pratica_com_ap_northeast_1.validation_record_value]
    type   = "CNAME"
    ttl    = 300
    },
  ]
  ses = {
    enable      = true
    dkim_tokens = module.ses.dkim_tokens_cloud_pratica
  }
}

module "iam_role" {
  source = "../modules/aws/iam_role"
  env    = local.env
}

module "s3" {
  source = "../modules/aws/s3"
  env    = local.env
  #   slack_metrics = {
  #     cloudfront_distribution_arn = module.cloudfront.arn_slack_metrics
  #   }
}

module "ecr" {
  source = "../modules/aws/ecr"
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

module "secrets_manager" {
  source = "../modules/aws/secrets_manager"
  env    = local.env
}

module "acm_cloud_pratica_com_ap_northeast_1" {
  source      = "../modules/aws/acm_unit"
  domain_name = "*.${local.base_host}"
  providers = {
    aws = aws
  }
}

module "acm_cloud_pratica_com_us_east_1" {
  source      = "../modules/aws/acm_unit"
  domain_name = "*.${local.base_host}"
  providers = {
    aws = aws.us_east_1
  }
}

module "ec2" {
  source           = "../modules/aws/ec2"
  env              = local.env
  public_subnet_id = module.subnet.id_public_subnet_1a
  bastion = {
    ami_id               = "ami-016675faa26f97391" // stg環境で構築した踏み台サーバのAMI ID
    iam_instance_profile = module.iam_role.instance_profile_cp_bastion
    security_group_id    = module.security_group.id_bastion
  }
  nat_1a = {
    ami_id               = "ami-0e7d55a65016b3c18" // stg環境で構築したNATインスタンスのAMI ID
    iam_instance_profile = module.iam_role.instance_profile_cp_nat
    security_group_id    = module.security_group.id_nat
  }
}

module "rds_cp" {
  env                  = local.env
  source               = "../modules/aws/rds_unit"
  identifier           = "cloud-pratica-${local.env}"
  db_name              = "slack_metrics"
  engine_version       = "16.8"
  instance_class       = "db.t3.micro"
  security_group_ids   = [module.security_group.id_db]
  private_subnet_ids   = local.private_subnet_ids
  subnet_group_name    = "cp-db-subnet-group-${local.env}"
  family               = "postgres16"
  parameter_group_name = "cp-db-parameter-group-${local.env}"
}

module "ecs" {
  source = "../modules/aws/ecs"
  env    = local.env
  slack_metrics_api = {
    name               = "slack-metrics-api-${local.env}"
    task_definition    = ""
    capacity_provider  = "FARGATE_SPOT"
    target_group_arn   = ""
    security_group_ids = [module.security_group.id_slack_metrics_backend]
    subnet_ids         = local.private_subnet_ids
  }
}

module "ecs_task_definition" {
  source                               = "../modules/aws/ecs_task_definition"
  env                                  = local.env
  ecs_task_role_arn_slack_metrics      = module.iam_role.role_arn_cp_slack_metrics_backend
  ecs_task_role_arn_db_migrator        = module.iam_role.role_arn_cp_db_migrator
  ecs_task_execution_role_arn          = module.iam_role.role_arn_ecs_task_execution
  arn_cp_config_bucket                 = module.s3.arn_cp_config_bucket
  ecr_url_slack_metrics                = "${module.ecr.url_slack_metrics}:6ab9854"
  secrets_manager_arn_db_main_instance = module.secrets_manager.arn_db_main_instance
  ecr_url_db_migrator                  = "${module.ecr.url_db_migrator}:6ab9854"
  ecs_task_specs = {
    slack_metrics_api = {
      cpu    = 256
      memory = 512
    }
    slack_metrics_batch = {
      cpu    = 256
      memory = 512
    }
    db_migrator = {
      cpu    = 256
      memory = 512
    }
  }
}
