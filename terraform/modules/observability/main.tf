locals {
  name_prefix = "${var.project_name}-${var.environment}-${var.service_name}"

  alb_dimension = regex(
    "loadbalancer/(.+)$",
    var.alb_arn
  )[0]

  target_group_dimension = regex(
    "(targetgroup/.+)$",
    var.target_group_arn
  )[0]
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${local.name_prefix}-ecs-cpu-high"
  alarm_description   = "ECS service CPU utilization is above the configured threshold."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = var.cpu_alarm_threshold

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"
  statistic   = "Average"
  period      = 300

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "${local.name_prefix}-ecs-memory-high"
  alarm_description   = "ECS service memory utilization is above the configured threshold."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = var.memory_alarm_threshold

  namespace   = "AWS/ECS"
  metric_name = "MemoryUtilization"
  statistic   = "Average"
  period      = 300

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  alarm_name          = "${local.name_prefix}-target-5xx"
  alarm_description   = "Application targets generated 5XX responses above the configured threshold."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.target_5xx_alarm_threshold

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"
  statistic   = "Sum"
  period      = 300

  dimensions = {
    LoadBalancer = local.alb_dimension
    TargetGroup  = local.target_group_dimension
  }

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${local.name_prefix}-unhealthy-hosts"
  alarm_description   = "Application Load Balancer target group contains unhealthy targets."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = var.unhealthy_host_alarm_threshold

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"
  statistic   = "Maximum"
  period      = 60

  dimensions = {
    LoadBalancer = local.alb_dimension
    TargetGroup  = local.target_group_dimension
  }

  treat_missing_data = "notBreaching"
}
