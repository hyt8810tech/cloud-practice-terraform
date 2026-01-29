variable "env" {
  type = string
}
variable "slack_metrics" {
  type = object({
    aliases             = list(string)
    acm_certificate_arn = string
    amplify_domain_name = string
    s3_domain_name      = string
    }
  )
}
locals {
  cache_policy_id_disabled  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  cache_policy_id_optimized = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  origin_request_policy_id  = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
  origin_id_amplify         = "amplify-slack-metrics-${var.env}"
  origin_id_s3              = "s3-slack-metrics-${var.env}"
}
