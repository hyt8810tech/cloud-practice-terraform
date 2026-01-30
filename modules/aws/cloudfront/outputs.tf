output "arn_slack_metrics" {
  value = aws_cloudfront_distribution.slack_metrics.arn
}

output "domain_name_slack_metrics" {
  value = aws_cloudfront_distribution.slack_metrics.domain_name
}

output "zone_id_us_east_1" {
  value = "Z2FDTNDATAQYW2"
}