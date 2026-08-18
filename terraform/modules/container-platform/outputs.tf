output "vpc_id" {
  description = "ID of the platform VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the platform public subnets."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the platform private subnets."
  value       = module.network.private_subnet_ids
}

output "private_route_table_id" {
  description = "ID of the private route table."
  value       = module.network.private_route_table_id
}

output "ecs_task_security_group_id" {
  description = "ID of the security group attached to ECS tasks."
  value       = module.network.ecs_task_security_group_id
}

output "vpc_endpoint_ids" {
  description = "IDs of the VPC endpoints used by the platform."
  value       = module.vpc_endpoints.endpoint_ids
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = module.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = module.ecs_cluster.cluster_arn
}

output "cloudwatch_log_group_names" {
  description = "CloudWatch log group names keyed by application service."
  value = {
    for service_name, service in module.ecs_services :
    service_name => service.cloudwatch_log_group_name
  }
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the IAM role used by ECS to execute tasks."
  value       = module.ecs_task_execution.role_arn
}

output "ecs_task_definition_arns" {
  description = "ECS task definition ARNs keyed by application service."
  value = {
    for service_name, service in module.ecs_services :
    service_name => service.task_definition_arn
  }
}

output "ecs_service_names" {
  description = "ECS service names keyed by application service."
  value = {
    for service_name, service in module.ecs_services :
    service_name => service.service_name
  }
}

output "ecs_service_arns" {
  description = "ECS service ARNs keyed by application service."
  value = {
    for service_name, service in module.ecs_services :
    service_name => service.service_arn
  }
}
