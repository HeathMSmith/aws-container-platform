output "ecr_repository_name" {
  description = "Name of the ECR repository."
  value       = data.aws_ecr_repository.app.name
}

output "ecr_repository_url" {
  description = "URL used to push and pull container images."
  value       = data.aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository."
  value       = data.aws_ecr_repository.app.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs_services.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = module.ecs_services.cluster_arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group used by ECS tasks."
  value       = module.ecs_services.cloudwatch_log_group_name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the IAM role used by ECS to execute tasks."
  value       = module.ecs_services.task_execution_role_arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition."
  value       = module.ecs_services.task_definition_arn
}

output "vpc_id" {
  description = "ID of the VPC used by the container platform."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets used by the Application Load Balancer."
  value       = module.network.public_subnet_ids
}

output "ecs_task_security_group_id" {
  description = "ID of the security group attached to ECS Fargate tasks."
  value       = module.network.ecs_task_security_group_id
}

output "ecs_service_name" {
  description = "Name of the ECS service running the container platform."
  value       = module.ecs_services.service_name
}

output "ecs_service_arn" {
  description = "ARN of the ECS service running the container platform."
  value       = module.ecs_services.service_arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = module.alb.arn
}

output "private_subnet_ids" {
  description = "IDs of the private subnets used by ECS Fargate tasks."
  value       = module.network.private_subnet_ids
}

output "private_route_table_id" {
  description = "ID of the route table associated with the private subnets."
  value       = module.network.private_route_table_id
}

output "vpc_endpoint_ids" {
  description = "IDs of the VPC endpoints used for private AWS service connectivity."
  value       = module.vpc_endpoints.endpoint_ids
}
