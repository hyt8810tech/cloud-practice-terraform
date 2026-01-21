resource "aws_secretsmanager_secret" "db_main_instance" {
  description = "RDS cloud-pratica main instance"
  name        = "db-main-instance-${var.env}"
}
