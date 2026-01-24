resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  provider = aws
}

