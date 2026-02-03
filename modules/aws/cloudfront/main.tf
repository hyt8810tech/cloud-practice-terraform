resource "aws_cloudfront_distribution" "slack_metrics" {
  aliases             = var.slack_metrics.aliases
  comment             = "slack-metrics-${var.env}"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  staging             = false
  wait_for_deployment = true
  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cache_policy_id            = local.cache_policy_id_disabled
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    origin_request_policy_id   = local.origin_request_policy_id
    smooth_streaming           = false
    target_origin_id           = local.origin_id_amplify
    viewer_protocol_policy     = "https-only"
    grpc_config {
      enabled = false
    }
  }
  ordered_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cache_policy_id            = local.cache_policy_id_optimized
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    path_pattern               = "/static/*"
    smooth_streaming           = false
    target_origin_id           = local.origin_id_s3
    viewer_protocol_policy     = "https-only"
    grpc_config {
      enabled = false
    }
  }
  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = var.slack_metrics.amplify_domain_name
    origin_id                = local.origin_id_amplify
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }
  origin {
    connection_attempts      = 3
    connection_timeout       = 10
    domain_name              = var.slack_metrics.s3_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_slack_metrics.id
    origin_id                = local.origin_id_s3
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn            = var.slack_metrics.acm_certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}


resource "aws_cloudfront_origin_access_control" "s3_slack_metrics" {
  description                       = "Created by CloudFront"
  name                              = local.origin_id_s3
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
