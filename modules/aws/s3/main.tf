module "cp_config" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "cp-hayato-config-${var.env}"

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
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "cp-slack-metrics-hayato-${var.env}"

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
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::cp-slack-metrics-hayato-${var.env}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}

