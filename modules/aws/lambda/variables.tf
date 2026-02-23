variable "env" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "slack_metrics" {
  type = object({
    role_arn = string
    image_uri = string
    security_group_id = string
    sqs_arn = string
  })
}