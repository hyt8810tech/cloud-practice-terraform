variable "env" {
  type = string
}
variable "slack_metrics" {
  type = object({
    lambda_invoke_arn = string
    domain_name = string
    deploy_version = string // Deployする場合はこの値を更新する
    cognito_user_pool_arn   = string
  })
}   
variable "main_certificate_arn" {
  type = string
}