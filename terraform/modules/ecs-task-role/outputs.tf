output "role_arn" {
  description = "ARN of the ECS application task role."
  value       = aws_iam_role.ecs_task.arn
}

output "role_name" {
  description = "Name of the ECS application task role."
  value       = aws_iam_role.ecs_task.name
}
