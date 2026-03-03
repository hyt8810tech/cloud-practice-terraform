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
  aws_account_id = local.account_id
}
module "ec2" {
  source           = "../modules/aws/ec2"
  env              = local.env
  public_subnet_id = module.subnet.id_public_subnet_1a
  bastion = {
    ami_id               = "ami-016675faa26f97391" // 踏み台サーバのAMI ID
    iam_instance_profile = module.iam_role.instance_profile_cp_bastion
    security_group_id    = module.security_group.id_bastion
  }
  nat_1a = {
    ami_id               = "ami-0e7d55a65016b3c18" // NATインスタンスのAMI ID
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

module "ecs" {
  source = "../modules/aws/ecs"
  env    = local.env
  slack_metrics_api = {
    name               = "slack-metrics-api-${local.env}"
    task_definition    = module.ecs_task_definition.arn_slack_metrics_api
    capacity_provider  = "FARGATE_SPOT"
    target_group_arn   = module.target_group.arn_slack_metrics_api
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
  ecr_url_slack_metrics                = "${module.ecr.url_slack_metrics}:0fc3124"
  secrets_manager_arn_db_main_instance = module.secrets_manager.arn_db_main_instance
  ecr_url_db_migrator                  = "${module.ecr.url_db_migrator}:c6db94b"
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

module "event_bridge_scheduler" {
  source             = "../modules/aws/event_bridge_scheduler"
  env                = local.env
  private_subnet_ids = local.private_subnet_ids
  slack_metrics = {
    iam_role_arn                             = module.iam_role.role_arn_cp_scheduler_slack_metrics
    ecs_cluster_arn                          = module.ecs.ecs_cluster_arn_cloud_pratica_backend
    security_group_id                        = module.security_group.id_slack_metrics_backend
    ecs_task_definition_arn_without_revision = module.ecs_task_definition.arn_without_revision_slack_metrics_batch
  }
  cost_cutter = {
    enable       = true
    iam_role_arn = module.iam_role.role_arn_cp_scheduler_cost_cutter
    ec2_instance_ids = [
      module.ec2.id_nat_1a,
      module.ec2.id_bastion,
    ]
    ecs_cluster_arn_cloud_pratica_backend = module.ecs.ecs_cluster_arn_cloud_pratica_backend
  }
  slack_metrics_v3 = {
    lambda_arn = module.lambda.arn_slack_metrics_batch
  }
}

module "target_group" {
  source = "../modules/aws/target_group"
  env    = local.env
  vpc_id = module.vpc.id_cloud_pratica
}

# module "alb" {
#   source = "../modules/aws/alb"
#   env    = local.env
#   cloud_pratica = {
#     security_group_ids                 = [module.security_group.id_alb]
#     subnet_ids                         = local.public_subnet_ids
#     arn_target_group_slack_metrics_api = module.target_group.arn_slack_metrics_api
#     slack_metrics_api_host             = local.slack_metrics_api_host
#     arn_certificate                    = module.acm_cloud_pratica_com_ap_northeast_1.arn_certificate
#   }
# }

module "s3" {
  source = "../modules/aws/s3"
  env    = local.env
  slack_metrics = {
    cloudfront_distribution_arn = module.cloudfront.arn_slack_metrics
  }
}


module "cloudfront" {
  source = "../modules/aws/cloudfront"
  env    = local.env
  slack_metrics = {
    aliases             = ["sm.${local.base_host}"]
    acm_certificate_arn = module.acm_cloud_pratica_com_us_east_1.arn_certificate
    amplify_domain_name = local.amplify_domain_name_slack_metrics
    s3_domain_name      = module.s3.domain_name_slack_metrics
  }
}

module "route53" {
  source    = "../modules/aws/route53_unit"
  zone_name = local.base_host
  records = [
    {
      name = local.slack_metrics_host
      type = "A"
      alias = {
        name                   = module.cloudfront.domain_name_slack_metrics
        evaluate_target_health = false
        zone_id                = module.cloudfront.zone_id_us_east_1
      }
    },
    # {
    #   name = local.slack_metrics_api_host
    #   type = "A"
    #   alias = {
    #     name                   = "dualstack.${module.alb.dns_name_cloud_pratica}"
    #     evaluate_target_health = true
    #     zone_id                = module.alb.zone_id_ap_northeast_1
    #   }
    # },
    {
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

module "parameter_store" {
  source = "../modules/aws/parameter_store"
  env    = local.env
  private_subnet_id_1a = module.subnet.id_private_subnet_1a
  private_subnet_id_1c = module.subnet.id_private_subnet_1c
  s3_arn_cp_config = module.s3.arn_cp_config_bucket
  aws_account_id = local.account_id
  sg_id_slack_metrics_backend = module.security_group.id_slack_metrics_backend
  sg_id_db_migrator = module.security_group.id_db_migrator
  tg_arn_slack_metrics_api = module.target_group.arn_slack_metrics_api
}

module "oidc_github_actions" {
  source = "../modules/aws/oidc_github_actions"
}

module "lambda" {
  source = "../modules/aws/lambda"
  env    = local.env
  private_subnet_ids = local.private_subnet_ids
  slack_metrics = {
    role_arn = module.iam_role.role_arn_slack_metrics_lambda
    image_uri = "${module.ecr.url_slack_metrics_lambda}:dbac188"
    security_group_id = module.security_group.id_slack_metrics_lambda
    sqs_arn = module.sqs.arn_slack_metrics
    api_gateway_id    = module.api_gateway.id_slack_metrics
  }
  aws_account_id = local.account_id
}

module "api_gateway" {
  source = "../modules/aws/api_gateway"
  env = local.env
  slack_metrics = {
    lambda_invoke_arn = module.lambda.invoke_arn_slack_metrics_api
    domain_name = "sm-api-v4.${local.base_host}"
    deploy_version = "5" // API Gatewayのデプロイを行う場合はこの値をインクリメントする
    cognito_user_pool_arn = module.cognito.user_pool_arn_slack_metrics
  }
  main_certificate_arn = module.acm_cloud_pratica_com_ap_northeast_1.arn_certificate
}

module "cognito" {
  source = "../modules/aws/cognito"
  env = local.env
}
