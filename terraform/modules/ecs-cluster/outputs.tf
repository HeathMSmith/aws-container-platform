output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.app.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = aws_ecs_cluster.app.arn
}

output "cluster_id" {
  description = "ID of the ECS cluster."
  value       = aws_ecs_cluster.app.id
}
