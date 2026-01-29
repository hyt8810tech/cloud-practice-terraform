module "cp_config" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"
  bucket  = "cp-hayato-config-${var.env}"

  versioning = {
    enabled = true
  }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }
}

module "cp_slack_metrics" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.7.0"
  bucket  = "cp-slack-metrics-hayato-${var.env}"

  versioning = {
    enabled = true
  }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
      bucket_key_enabled = true
    }
  }
  lifecycle_rule = [
    {
      id      = "noncurrent-version-expiration"
      enabled = true
      noncurrent_version_expiration = {
        days = 90
      }
      filter = {
        prefix = ""
      }
    }
  ]
}

resource "aws_s3_bucket_policy" "slack_metrics" {
  count  = var.slack_metrics.cloudfront_distribution_arn != null ? 1 : 0
  bucket = module.cp_slack_metrics.s3_bucket_id
  policy = jsonencode({
    "Version" : "2008-10-17",
    Id = "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        Sid = "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${module.cp_slack_metrics.s3_bucket_id}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : var.slack_metrics.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}
