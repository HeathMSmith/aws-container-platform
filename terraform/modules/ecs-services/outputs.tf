output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group used by ECS tasks."
  value       = aws_cloudwatch_log_group.app.name
}

output "task_execution_role_arn" {
  description = "ARN of the IAM role used by ECS to execute tasks."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition."
  value       = aws_ecs_task_definition.app.arn
}

output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.app.name
}

output "service_arn" {
  description = "ARN of the ECS service."
  value       = aws_ecs_service.app.id
}
