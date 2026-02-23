variable "env" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}
variable "slack_metrics" {
  type = object({
    ecs_cluster_arn = string
    iam_role_arn = string
    security_group_id = string
    ecs_task_definition_arn_without_revision = string
  })
}
variable "slack_metrics_v3" {
  type = object({
    lambda_arn = string
  })
  default = null
}
variable "cost_cutter" {
  type = object({
    enable = bool
    iam_role_arn = string
    ec2_instance_ids = list(string)
    ecs_cluster_arn_cloud_pratica_backend = string
  })
}
locals {
  rds_identifier_cloud_pratica = "cloud-pratica-${var.env}"
}