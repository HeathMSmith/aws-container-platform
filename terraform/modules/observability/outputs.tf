output "ecs_cpu_high_alarm_arn" {
  description = "ARN of the ECS high CPU utilization CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.ecs_cpu_high.arn
}

output "ecs_memory_high_alarm_arn" {
  description = "ARN of the ECS high memory utilization CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.ecs_memory_high.arn
}

output "target_5xx_alarm_arn" {
  description = "ARN of the target-generated 5XX CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.target_5xx.arn
}

output "unhealthy_hosts_alarm_arn" {
  description = "ARN of the unhealthy target CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.unhealthy_hosts.arn
}
