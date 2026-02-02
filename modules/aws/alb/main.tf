resource "aws_lb" "cloud_pratica" {
  name                                        = "cp-alb-${var.env}"
  client_keep_alive                           = 3600
  idle_timeout                                = 60
  ip_address_type                             = "ipv4"
  load_balancer_type                          = "application"
  security_groups                             = var.cloud_pratica.security_group_ids
  subnets                                     = var.cloud_pratica.subnet_ids
}

resource "aws_lb_listener_rule" "slack_metrics_api" {
  listener_arn = aws_lb_listener.cp_https.arn
  priority     = 1
  tags = {
    Name = "slack-metrics-api"
  }
  tags_all = {
    Name = "slack-metrics-api"
  }
  action {
    order            = 1
    target_group_arn = var.cloud_pratica.arn_target_group_slack_metrics_api
    type             = "forward"
  }
  condition {
    host_header {
      values = [var.cloud_pratica.slack_metrics_api_host]
    }
  }
}

resource "aws_lb_listener" "cp_https" {
  certificate_arn                      = var.cloud_pratica.arn_certificate
  load_balancer_arn                    = aws_lb.cloud_pratica.arn
  port                                 = 443
  protocol                             = "HTTPS"
  routing_http_response_server_enabled = true
  ssl_policy                           = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
  default_action {
    order            = 1
    target_group_arn = null
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "403 forbidden"
      status_code  = "403"
    }
  }

}
