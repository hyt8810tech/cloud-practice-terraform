output "domain_name_slack_metrics" {
  value = module.cp_slack_metrics.s3_bucket_bucket_regional_domain_name
}

output "arn_cp_config_bucket" {
  value = module.cp_config.s3_bucket_arn
}