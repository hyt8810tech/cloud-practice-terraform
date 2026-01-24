resource "aws_ecs_cluster" "cloud_pratica_backend" {
  name     = "cloud-pratica-backend-${var.env}"
  configuration {
    execute_command_configuration {
      logging    = "DEFAULT"
    }
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "cloud_pratica_backend" {
  cluster_name = aws_ecs_cluster.cloud_pratica_backend.name
  capacity_providers = ["FARGATE","FARGATE_SPOT"]
  }
