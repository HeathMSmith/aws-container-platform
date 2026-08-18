locals {
  alb_dimension = regex(
    "loadbalancer/(.+)$",
    var.alb_arn
  )[0]
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-5xx"
  alarm_description   = "Application Load Balancer generated 5XX responses above the configured threshold."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = var.alb_5xx_alarm_threshold

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"
  statistic   = "Sum"
  period      = 300

  dimensions = {
    LoadBalancer = local.alb_dimension
  }

  treat_missing_data = "notBreaching"
}
