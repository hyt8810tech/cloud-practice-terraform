resource "aws_db_proxy" "cloud_pratica" {
  name                   = "cloud-pratica-${var.env}"
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = var.cloud_pratica.iam_role_arn
  vpc_security_group_ids = [var.cloud_pratica.security_group_id]
  vpc_subnet_ids         = var.cloud_pratica.private_subnet_ids
    auth {
    auth_scheme               = "SECRETS"
    description               = null
    iam_auth                  = "REQUIRED"
    secret_arn                = var.cloud_pratica.secrets_manager_arn
    client_password_auth_type = "POSTGRES_SCRAM_SHA_256"
  }
}

resource "aws_db_proxy_default_target_group" "cloud_pratica" {
  db_proxy_name = "cloud-pratica-${var.env}"
  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 50
    max_idle_connections_percent = 25
  }
}

resource "aws_db_proxy_target" "cloud_pratica" {
  db_instance_identifier = "cloud-pratica-${var.env}"
  db_proxy_name          = aws_db_proxy.cloud_pratica.name
  target_group_name      = aws_db_proxy_default_target_group.cloud_pratica.name
}
