output "alb_5xx_alarm_arn" {
  description = "ARN of the shared ALB-generated 5XX CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.alb_5xx.arn
}
