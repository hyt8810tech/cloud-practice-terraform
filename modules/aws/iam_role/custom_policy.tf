/**********************************************************
secrets-manager-read
**********************************************************/
resource "aws_iam_policy" "secrets_manager_read" {
  description = "secrets-manager-readonly-${var.env}"
  policy = jsonencode({
    Statement = [{
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Effect   = "Allow"
      Resource = "*"
      Sid      = "VisualEditor0"
    }]
    Version = "2012-10-17"
  })
}

/**********************************************************
sqs-read-write
**********************************************************/
resource "aws_iam_policy" "sqs_read_write" {
  policy = jsonencode({
    Statement = [{
      Action = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

/**********************************************************
ses-send-email
**********************************************************/
resource "aws_iam_policy" "ses_send_email" {
  policy = jsonencode({
    Statement = [{
      Action = [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

/**********************************************************
cloud-watch-logs-write
**********************************************************/
resource "aws_iam_policy" "cloud_watch_logs_write" {
  name = "cloud-watch-logs-write-${var.env}"
  policy = jsonencode({
    Statement = [{
      Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

/**********************************************************
ecs-run-task
**********************************************************/
resource "aws_iam_policy" "ecs_run_task" {
  name = "ecs-run-task-${var.env}"
  policy = jsonencode({
    Statement = [{
      Action   = "ecs:RunTask"
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

/**********************************************************
pass-role-to-ecs-task
**********************************************************/
resource "aws_iam_policy" "pass_role_to_ecs_task" {
  name = "pass-role-to-ecs-task-stg"
  policy = jsonencode({
    Statement = [{
      Action = "iam:PassRole"
      Condition = {
        StringEquals = {
          "iam:PassedToService" = "ecs-tasks.amazonaws.com"
        }
      }
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

/**********************************************************
batch-submit-job
**********************************************************/
resource "aws_iam_policy" "batch_submit_job" {
  name = "batch-submit-job-stg"
  policy = jsonencode({
    Statement = [{
      Action   = ["batch:SubmitJob"]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

/**********************************************************
lambda-invoke
**********************************************************/
resource "aws_iam_policy" "lambda_invoke" {
  name = "lambda-invoke-${var.env}"
  policy = jsonencode({
    Statement = [{
      Action   = ["lambda:InvokeFunction", "lambda:GetFunctionConfiguration"]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

/**********************************************************
rds-start-stop
**********************************************************/
resource "aws_iam_policy" "rds_start_stop" {
  description = null
  name        = "rds-start-stop-${var.env}"
  path        = "/"
  policy = jsonencode({
    Statement = [{
      Action   = ["rds:StartDBInstance", "rds:StopDBInstance"]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

/**********************************************************
ec2-start-stop
**********************************************************/
resource "aws_iam_policy" "ec2_start_stop" {
  description = null
  name        = "ec2-start-stop-${var.env}"
  path        = "/"
  policy = jsonencode({
    Statement = [{
      Action   = ["ec2:StartInstances", "ec2:StopInstances"]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

/**********************************************************
ecs-write
**********************************************************/
resource "aws_iam_policy" "ecs_write" {
  description = null
  name        = "ecs-write-${var.env}"
  path        = "/"
  policy = jsonencode({
    Statement = [{
      Action   = ["ecs:UpdateService", "ecs:RunTask"]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}
