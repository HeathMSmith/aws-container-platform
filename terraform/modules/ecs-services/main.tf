locals {
  service_name_prefix = "${var.project_name}-${var.environment}-${var.service_name}"
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.service_name_prefix}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_ecs_task_definition" "app" {
  family                   = local.service_name_prefix
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.task_cpu
  memory = var.task_memory

  execution_role_arn = var.task_execution_role_arn

  container_definitions = jsonencode([
    {
      name                   = var.service_name
      image                  = var.container_image
      essential              = true
      readonlyRootFilesystem = true

      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
        }
      }

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:${var.container_port}/health')\" || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = local.service_name_prefix
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets = var.private_subnet_ids

    security_groups = [
      var.ecs_task_security_group_id
    ]

    assign_public_ip = false
  }

  lifecycle {
    create_before_destroy = true

    ignore_changes = [
      desired_count
    ]
  }
}
