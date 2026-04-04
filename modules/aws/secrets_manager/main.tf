resource "aws_secretsmanager_secret" "db_main_instance" {
  description = "RDS cloud-pratica main instance"
  name        = "db-main-instance-${var.env}"
}

resource "aws_secretsmanager_secret" "db_slack_metrics" {
    count       = var.enable_db_slack_metrics ? 1 : 0
  description = "DB credentials for Slack Metrics"
  name        = "db-slack-metrics-${var.env}"
}
