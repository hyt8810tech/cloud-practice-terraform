/**********************************************************
slack-metrics-api
**********************************************************/
resource "aws_lambda_function" "slack_metrics_api" {
  architectures                  = ["x86_64"]
  function_name                  = "slack-metrics-api-${var.env}"
  image_uri                      = var.slack_metrics.image_uri
  memory_size                    = 256
  package_type                   = "Image"
  region                         = "ap-northeast-1"
  reserved_concurrent_executions = -1
  role                           = var.slack_metrics.role_arn
  skip_destroy                   = false
  timeout                        = 60
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
    security_group_ids = [
      var.slack_metrics.security_group_id
    ]
    subnet_ids = var.private_subnet_ids
  }
  lifecycle {
    ignore_changes = [image_uri]
  }
}
/**********************************************************
slack-metrics-batch
**********************************************************/
resource "aws_lambda_function" "slack_metrics_batch" {
  architectures                  = ["x86_64"]
  function_name                  = "slack-metrics-batch-${var.env}"
  image_uri                      = var.slack_metrics.image_uri
  memory_size                    = 1024
  package_type                   = "Image"
  region                         = "ap-northeast-1"
  reserved_concurrent_executions = -1
  role                           = var.slack_metrics.role_arn
  skip_destroy                   = false
  timeout                        = 900
  environment {
    variables = {
      ENV  = var.env
      MODE = "batch"
    }
  }
  ephemeral_storage {
    size = 512
  }
  vpc_config {
    security_group_ids = [
      var.slack_metrics.security_group_id
    ]
    subnet_ids = var.private_subnet_ids
  }
  lifecycle {
    ignore_changes = [image_uri]
  }
}
/**********************************************************
slack-metrics-worker
**********************************************************/
resource "aws_lambda_function" "slack_metrics_worker" {
  architectures                  = ["x86_64"]
  function_name                  = "slack-metrics-worker-${var.env}"
  image_uri                      = var.slack_metrics.image_uri
  memory_size                    = 1024
  package_type                   = "Image"
  region                         = "ap-northeast-1"
  reserved_concurrent_executions = -1
  role                           = var.slack_metrics.role_arn
  skip_destroy                   = false
  timeout                        = 900
  environment {
    variables = {
      ENV  = var.env
      MODE = "sqs"
    }
  }
  ephemeral_storage {
    size = 512
  }
  vpc_config {
    security_group_ids = [
      var.slack_metrics.security_group_id
    ]
    subnet_ids = var.private_subnet_ids
  }
  lifecycle {
    ignore_changes = [image_uri]
  }
}

resource "aws_lambda_event_source_mapping" "slack_metrics_worker" {
  count            = var.slack_metrics.sqs_arn != null ? 1 : 0
  batch_size       = 10
  enabled          = true
  event_source_arn = var.slack_metrics.sqs_arn
  function_name    = aws_lambda_function.slack_metrics_worker.function_name
  region           = "ap-northeast-1"
}
