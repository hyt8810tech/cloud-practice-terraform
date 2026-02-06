/**********************************************************
slack-metrics-api
**********************************************************/

resource "aws_ecs_task_definition" "slack_metrics_api" {
  family                   = "slack-metrics-api-${var.env}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_specs.slack_metrics_api.cpu
  memory                   = var.ecs_task_specs.slack_metrics_api.memory
  task_role_arn            = var.ecs_task_role_arn_slack_metrics
  execution_role_arn       = var.ecs_task_execution_role_arn
  network_mode             = "awsvpc"


  container_definitions = jsonencode([{
    name        = "api"
    environment = []
    environmentFiles = [{
      type  = "s3"
      value = "${var.arn_cp_config_bucket}/slack-metrics-${var.env}.env"
    }]
    essential = true
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8080/api/health || exit 1"]
      interval    = 10
      retries     = 3
      startPeriod = 0
      timeout     = 5
    }
    image = "${var.ecr_url_slack_metrics}"
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "/ecs/slack-metrics-api-${var.env}"
        awslogs-region        = "ap-northeast-1"
        awslogs-stream-prefix = "ecs"
      }
      secretOptions = []
    }
    mountPoints = []
    portMappings = [{
      appProtocol   = "http"
      containerPort = 8080
      hostPort      = 8080
      name          = "api-8080-tcp"
      protocol      = "tcp"
    }]
    readonlyRootFilesystem = false
    secrets = [{
      name      = "POSTGRES_MAIN_HOST"
      valueFrom = "${var.secrets_manager_arn_db_main_instance}:host::"
      }, {
      name      = "POSTGRES_MAIN_PASSWORD"
      valueFrom = "${var.secrets_manager_arn_db_main_instance}:slack_metrics_password::"
      }, {
      name      = "POSTGRES_MAIN_USER"
      valueFrom = "${var.secrets_manager_arn_db_main_instance}:slack_metrics_user::"
    }]
    systemControls = []
    ulimits        = []
    volumesFrom    = []
    }, {
    name = "worker"
    environment = [{
      name  = "MODE"
      value = "sqs"
    }]
    environmentFiles = [{
      type  = "s3"
      value = "${var.arn_cp_config_bucket}/slack-metrics-${var.env}.env"
    }]
    essential = true
    healthCheck = {
      command     = ["CMD-SHELL", "ps aux | grep main | grep -v grep || exit 1"]
      interval    = 10
      retries     = 3
      startPeriod = 0
      timeout     = 5
    }
    image = "${var.ecr_url_slack_metrics}"
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "/ecs/slack-metrics-worker-${var.env}"
        awslogs-region        = "ap-northeast-1"
        awslogs-stream-prefix = "ecs"
      }
      secretOptions = []
    }
    mountPoints            = []
    portMappings           = []
    readonlyRootFilesystem = true
    secrets = [{
      name      = "POSTGRES_MAIN_HOST"
      valueFrom = "${var.secrets_manager_arn_db_main_instance}:host::"
      }, {
      name      = "POSTGRES_MAIN_PASSWORD"
      valueFrom = "${var.secrets_manager_arn_db_main_instance}:slack_metrics_password::"
      }, {
      name      = "POSTGRES_MAIN_USER"
      valueFrom = "${var.secrets_manager_arn_db_main_instance}:slack_metrics_user::"
    }]
    stopTimeout    = 120
    systemControls = []
    volumesFrom    = []
  }])
  lifecycle {
    ignore_changes = [container_definitions]
  }
}
/**********************************************************
slack-metrics-batch
**********************************************************/
resource "aws_ecs_task_definition" "slack_metrics_batch" {
  family                   = "slack-metrics-batch-${var.env}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_specs.slack_metrics_batch.cpu
  memory                   = var.ecs_task_specs.slack_metrics_batch.memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn_slack_metrics
  network_mode             = "awsvpc"

  container_definitions = jsonencode([{
    name = "batch"
    environment = [{
      name  = "MODE"
      value = "batch"
    }]
    environmentFiles = [{
      type  = "s3"
      value = "${var.arn_cp_config_bucket}/slack-metrics-${var.env}.env"
    }]
    essential = true
    image     = "${var.ecr_url_slack_metrics}"
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "/ecs/slack-metrics-batch-${var.env}"
        awslogs-region        = "ap-northeast-1"
        awslogs-stream-prefix = "ecs"
      }
      secretOptions = []
    }
    mountPoints = []
    portMappings = [{
      appProtocol   = "http"
      containerPort = 80
      hostPort      = 80
      name          = "batch-80-tcp"
      protocol      = "tcp"
    }]
    readonlyRootFilesystem = true
    secrets = [{
      name      = "POSTGRES_MAIN_HOST"
      valueFrom = "${var.secrets_manager_arn_db_main_instance}:host::"
      }, {
      name      = "POSTGRES_MAIN_PASSWORD"
      valueFrom = "${var.secrets_manager_arn_db_main_instance}:slack_metrics_password::"
      }, {
      name      = "POSTGRES_MAIN_USER"
      valueFrom = "${var.secrets_manager_arn_db_main_instance}:slack_metrics_user::"
    }]
    systemControls = []
    ulimits        = []
    volumesFrom    = []
  }])
  lifecycle {
    ignore_changes = [container_definitions]
  }
}

/**********************************************************
db-migrator
**********************************************************/
resource "aws_ecs_task_definition" "db_migrator" {
  family                   = "db-migrator-${var.env}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_specs.db_migrator.cpu
  memory                   = var.ecs_task_specs.db_migrator.memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn_db_migrator
  network_mode             = "awsvpc"

  container_definitions = jsonencode([{
    name        = "app"
    environment = []
    environmentFiles = [{
      type  = "s3"
      value = "${var.arn_cp_config_bucket}/db-migrator-${var.env}.env"
    }]
    essential = true
    image     = "${var.ecr_url_db_migrator}"
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "/ecs/db-migrator-${var.env}"
        awslogs-region        = "ap-northeast-1"
        awslogs-stream-prefix = "ecs"
      }
      secretOptions = []
    }
    mountPoints            = []
    portMappings           = []
    readonlyRootFilesystem = true
    secrets = [{
      name      = "DB_HOST"
      valueFrom = "${var.secrets_manager_arn_db_main_instance}:host::"
      }, {
      name      = "DB_PASSWORD"
      valueFrom = "${var.secrets_manager_arn_db_main_instance}:operator_password::"
      }, {
      name      = "DB_USER"
      valueFrom = "${var.secrets_manager_arn_db_main_instance}:operator_user::"
    }]
    systemControls = []
    ulimits        = []
    volumesFrom    = []
  }])
  lifecycle {
    ignore_changes = [container_definitions]
  }
}

