resource "aws_lambda_function" "slack_metrics_api" {
  architectures                      = ["x86_64"]
  function_name                      = "slack-metrics-api-${var.env}"
  image_uri                          = var.slack_metrics.image_uri
  memory_size                        = 128
  package_type                       = "Image"
  region                             = "ap-northeast-1"
  reserved_concurrent_executions     = -1
  role                               = var.slack_metrics.role_arn
  skip_destroy                       = false
  timeout                            = 3
  environment {
    variables = {
      ENV  = var.env
      MODE = "api"
    }
  }
  ephemeral_storage {
    size = 512
  }
  vpc_config {
    security_group_ids          = [
        var.slack_metrics.security_group_id
        ]
    subnet_ids                  = var.private_subnet_ids
  }
  lifecycle {
    ignore_changes = [image_uri]
  }
}
