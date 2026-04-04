output "arn_db_main_instance" {
  value = aws_secretsmanager_secret.db_main_instance.arn
}

output "arn_db_slack_metrics" {
  value = var.enable_db_slack_metrics ? aws_secretsmanager_secret.db_slack_metrics[0].arn : null
}
