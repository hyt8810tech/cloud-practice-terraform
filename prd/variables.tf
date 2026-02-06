locals {
  env        = "prd"
  account_id = "165115313503"
  region     = "ap-northeast-1"
  base_host  = "8810-infra.click"
  slack_metrics_host = "sm.${local.base_host}"
  slack_metrics_api_host = "sm-api.${local.base_host}"
  amplify_domain_name_slack_metrics = "main.d3frdxuhjsb93b.amplifyapp.com"
  public_subnet_ids = [
    module.subnet.id_public_subnet_1a,
    module.subnet.id_public_subnet_1c,
  ]
  private_subnet_ids = [
    module.subnet.id_private_subnet_1a,
    module.subnet.id_private_subnet_1c,
  ]
  private_subnet_cidr_blocks = [
    module.subnet.cidr_block_private_1a,
    module.subnet.cidr_block_private_1c,
  ]
}

