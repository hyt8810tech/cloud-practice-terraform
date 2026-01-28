variable "env" {
  type = string
}
variable "cloud_pratica" {
  type = object({
    security_group_ids = list(string)
    subnet_ids        = list(string)
    arn_target_group_slack_metrics_api = string
    slack_metrics_api_host = string
    arn_certificate = string
  })

}