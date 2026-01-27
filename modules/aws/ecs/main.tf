/**********************************************************
ecs cluster cloud-pratica-backend
**********************************************************/
resource "aws_ecs_cluster" "cloud_pratica_backend" {
  name = "cloud-pratica-backend-${var.env}"
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "cloud_pratica_backend" {
  cluster_name       = aws_ecs_cluster.cloud_pratica_backend.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

/**********************************************************
ecs service slack-metrics-api
**********************************************************/
resource "aws_ecs_service" "slack_metrics_api" {
  cluster                            = aws_ecs_cluster.cloud_pratica_backend.arn
  name                               = var.slack_metrics_api.name
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 0
  enable_ecs_managed_tags            = true
  enable_execute_command             = true
  health_check_grace_period_seconds  = 0
  task_definition                    = var.slack_metrics_api.task_definition
  capacity_provider_strategy {
    base              = 0
    capacity_provider = var.slack_metrics_api.capacity_provider
    weight            = 1
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }
  dynamic "load_balancer" {
    for_each = var.slack_metrics_api.target_group_arn != null ? [1] : []
    content {
      container_name   = "api"
      container_port   = 8080
      elb_name         = null
      target_group_arn = var.slack_metrics_api.target_group_arn
    }
  }
  network_configuration {
    assign_public_ip = false
    security_groups  = var.slack_metrics_api.security_group_ids
    subnets          = var.slack_metrics_api.subnet_ids
  }
}


resource "aws_appautoscaling_target" "slack_metrics_api" {
  service_namespace  = "ecs"
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cloud_pratica_backend.name}/${var.slack_metrics_api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  depends_on         = [aws_ecs_service.slack_metrics_api]
}

resource "aws_appautoscaling_policy" "slack_metrics_api_cpu" {
  name               = "target-tracking-cpu"
  policy_type        = "TargetTrackingScaling"
  region             = "ap-northeast-1"
  resource_id        = aws_appautoscaling_target.slack_metrics_api.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  target_tracking_scaling_policy_configuration {
    disable_scale_in   = false
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
    target_value       = 70
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "slack_metrics_api_memory" {
  name               = "target-tracking-memory"
  policy_type        = "TargetTrackingScaling"
  region             = "ap-northeast-1"
  resource_id        = aws_appautoscaling_target.slack_metrics_api.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  target_tracking_scaling_policy_configuration {
    disable_scale_in   = false
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
    target_value       = 70
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}


