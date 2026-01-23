//db-migrator
resource "aws_iam_role" "cp_db_migrator" {
  name = "cp-db-migrator-${var.env}"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  description = "Allows ECS tasks to call AWS services on your behalf."
  tags = {
    Name = "cp-db-migrator-${var.env}"
  }
  tags_all = {
    Name = "cp-db-migrator-${var.env}"
  }
}

//bastion
resource "aws_iam_role" "cp_bastion" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  name = "cp-bastion-${var.env}"
}

resource "aws_iam_role_policy_attachment" "cp_bastion" {
  for_each = {
    ssm_core = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  policy_arn = each.value
  role       = aws_iam_role.cp_bastion.name
}

resource "aws_iam_instance_profile" "cp_bastion" {
  name = "cp-bastion-${var.env}"
  role = aws_iam_role.cp_bastion.name
}

//nat
resource "aws_iam_role" "cp_nat" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  name = "cp-nat-${var.env}"
}

resource "aws_iam_role_policy_attachment" "cp_nat" {
  for_each = {
    ssm_core = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  policy_arn = each.value
  role       = aws_iam_role.cp_nat.name
}

resource "aws_iam_instance_profile" "cp_nat" {
  name = "cp-nat-${var.env}"
  role = aws_iam_role.cp_nat.name
}

//ecs-task-execution
resource "aws_iam_role" "ecs_task_execution" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        "Service" : "ecs-tasks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  name = "ecs-task-execution-${var.env}"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  for_each = {
    task_execution  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    s3              = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    secrets_manager = aws_iam_policy.secrets_manager_read.arn
    cloudwatch      = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  }
  policy_arn = each.value
  role       = aws_iam_role.ecs_task_execution.name
}


//slack-metrics-backend
resource "aws_iam_role" "cp_slack_metrics_backend" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        "Service" : "ecs-tasks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  name = "cp-slack-metrics-backend-${var.env}"
}

resource "aws_iam_role_policy_attachment" "cp_slack_metrics_backend" {
  for_each = {
    ssm_core   = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    cloudwatch = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    ses        = aws_iam_policy.ses_send_email.arn
    sqs        = aws_iam_policy.sqs_read_write.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.cp_slack_metrics_backend.name
}

//slack-metrics-client
resource "aws_iam_role" "cp_slack_metrics_client" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "amplify.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  name = "cp-slack-metrics-client-${var.env}"
}

resource "aws_iam_role_policy_attachment" "cp_slack_metrics_client" {
  for_each = {
    cloudwatch = aws_iam_policy.cloud_watch_logs_write.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.cp_slack_metrics_client.name
}


//cp-scheduler-slack-metrics
resource "aws_iam_role" "cp_scheduler_slack_metrics" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  name = "cp-scheduler-slack-metrics-${var.env}"
}

resource "aws_iam_role_policy_attachment" "cp_scheduler_slack_metrics" {
  for_each = {
    batch                 = aws_iam_policy.batch_submit_job.arn
    ecs_run_task          = aws_iam_policy.ecs_run_task.arn
    lambda                = aws_iam_policy.lambda_invoke.arn
    pass_role_to_ecs_task = aws_iam_policy.pass_role_to_ecs_task.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.cp_scheduler_slack_metrics.name
}

//cp-scheduler-cost-cutter-stg
resource "aws_iam_role" "cp_scheduler_cost_cutter" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  name = "cp-scheduler-cost-cutter-${var.env}"
}

resource "aws_iam_role_policy_attachment" "cp_scheduler_cost_cutter" {
  for_each = {
    rds_start_stop = aws_iam_policy.rds_start_stop.arn
    ec2_start_stop = aws_iam_policy.ec2_start_stop.arn
    ecs_write      = aws_iam_policy.ecs_write.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.cp_scheduler_cost_cutter.name
}

//administrator
resource "aws_iam_role" "administrator" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::043309350350:root"
      }
    }]
    Version = "2012-10-17"
  })
  name = "administrator-${var.env}"
}

resource "aws_iam_role_policy_attachment" "administrator" {
  for_each = {
    administrator = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
  policy_arn = each.value
  role       = aws_iam_role.administrator.name
}
