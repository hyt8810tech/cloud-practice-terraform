output "invoke_arn_slack_metrics_api" {
  value = aws_lambda_function.slack_metrics_api.invoke_arn
}

output "arn_slack_metrics_batch" {
  value = aws_lambda_function.slack_metrics_batch.arn
}