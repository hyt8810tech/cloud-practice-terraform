variable "env" {
}

variable "cloud_pratica" {
  type = object({
    iam_role_arn = string
    security_group_id = string
    private_subnet_ids = list(string)
    secrets_manager_arn = string
  })
}