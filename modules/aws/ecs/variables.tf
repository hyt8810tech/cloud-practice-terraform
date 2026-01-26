variable "env" {
  type = string
}
variable "slack_metrics_api" {
  type = object({
    name               = string
    task_definition    = string
    capacity_provider  = string
    target_group_arn   = string
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
}
