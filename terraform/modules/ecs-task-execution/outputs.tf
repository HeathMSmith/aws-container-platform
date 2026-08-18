output "role_arn" {
  description = "ARN of the shared ECS task execution role."
  value       = aws_iam_role.ecs_task_execution.arn
}
