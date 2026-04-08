/************************************************************
Slack Metrics API (REST)
************************************************************/
resource "aws_api_gateway_rest_api" "slack_metrics" {
  disable_execute_api_endpoint = true
  name                         = "slack-metrics-${var.env}"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
// リソース: /{proxy+}
resource "aws_api_gateway_resource" "slack_metrics_root" {
  parent_id   = aws_api_gateway_rest_api.slack_metrics.root_resource_id
  path_part   = "{proxy+}"
  rest_api_id = aws_api_gateway_rest_api.slack_metrics.id
}

// メソッド: ANY /{proxy+}
resource "aws_api_gateway_method" "slack_metrics_root_any" {
  api_key_required = false
  #authorization    = "COGNITO_USER_POOLS"
  authorization = "NONE"
  authorizer_id    = aws_api_gateway_authorizer.cognito_slack_metrics.id
  http_method      = "ANY"
  request_parameters = {
    "method.request.path.proxy" = true
  }
  resource_id = aws_api_gateway_resource.slack_metrics_root.id
  rest_api_id = aws_api_gateway_rest_api.slack_metrics.id
}
// Lambda関数とのProxy統合: ANY /{proxy+}
resource "aws_api_gateway_integration" "slack_metrics_root_any" {
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = aws_api_gateway_method.slack_metrics_root_any.http_method
  integration_http_method = "POST"
  resource_id             = aws_api_gateway_resource.slack_metrics_root.id
  rest_api_id             = aws_api_gateway_rest_api.slack_metrics.id
  type                    = "AWS_PROXY"
  uri                     = var.slack_metrics.lambda_invoke_arn
}

// ステージ: $default
resource "aws_api_gateway_stage" "slack_metrics_default" {
  deployment_id = aws_api_gateway_deployment.slack_metrics.id
  rest_api_id   = aws_api_gateway_rest_api.slack_metrics.id
  stage_name    = "default"
}

// カスタムドメイン
resource "aws_api_gateway_domain_name" "slack_metrics" {
  domain_name              = var.slack_metrics.domain_name
  regional_certificate_arn = var.main_certificate_arn
}
// カスタムドメインとAPIのマッピング
resource "aws_apigatewayv2_api_mapping" "slack_metrics" {
  api_id      = aws_api_gateway_rest_api.slack_metrics.id
  domain_name = aws_api_gateway_domain_name.slack_metrics.domain_name
  stage       = aws_api_gateway_stage.slack_metrics_default.stage_name
}

// デプロイ
resource "aws_api_gateway_deployment" "slack_metrics" {
  rest_api_id = aws_api_gateway_rest_api.slack_metrics.id
  triggers = {
    redeployment = sha1(jsonencode([
      var.slack_metrics.deploy_version
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

//オーソライザー
resource "aws_api_gateway_authorizer" "cognito_slack_metrics" {
  name            = "cognito-slack-metrics-${var.env}"
  provider_arns   = [var.slack_metrics.cognito_user_pool_arn]
  rest_api_id     = aws_api_gateway_rest_api.slack_metrics.id
  type            = "COGNITO_USER_POOLS"
}










