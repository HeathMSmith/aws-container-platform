output "ecr_repository_names" {
  description = "ECR repository names keyed by application service."
  value = {
    for key, repository in data.aws_ecr_repository.app :
    key => repository.name
  }
}

output "ecr_repository_urls" {
  description = "ECR repository URLs keyed by application service."
  value = {
    for key, repository in data.aws_ecr_repository.app :
    key => repository.repository_url
  }
}

output "ecr_repository_arns" {
  description = "ECR repository ARNs keyed by application service."
  value = {
    for key, repository in data.aws_ecr_repository.app :
    key => repository.arn
  }
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.container_platform.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = module.container_platform.ecs_cluster_arn
}

output "cloudwatch_log_group_names" {
  description = "CloudWatch log group names keyed by application service."
  value       = module.container_platform.cloudwatch_log_group_names
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the IAM role used by ECS to execute tasks."
  value       = module.container_platform.ecs_task_execution_role_arn
}

output "ecs_task_definition_arns" {
  description = "ECS task definition ARNs keyed by application service."
  value       = module.container_platform.ecs_task_definition_arns
}

output "vpc_id" {
  description = "ID of the VPC used by the container platform."
  value       = module.container_platform.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets used by the Application Load Balancer."
  value       = module.container_platform.public_subnet_ids
}

output "ecs_task_security_group_id" {
  description = "ID of the security group attached to ECS Fargate tasks."
  value       = module.container_platform.ecs_task_security_group_id
}

output "ecs_service_names" {
  description = "ECS service names keyed by application service."
  value       = module.container_platform.ecs_service_names
}

output "ecs_service_arns" {
  description = "ECS service ARNs keyed by application service."
  value       = module.container_platform.ecs_service_arns
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.container_platform.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = module.container_platform.alb_arn
}

output "private_subnet_ids" {
  description = "IDs of the private subnets used by ECS Fargate tasks."
  value       = module.container_platform.private_subnet_ids
}

output "private_route_table_id" {
  description = "ID of the route table associated with the private subnets."
  value       = module.container_platform.private_route_table_id
}

output "vpc_endpoint_ids" {
  description = "IDs of the VPC endpoints used for private AWS service connectivity."
  value       = module.container_platform.vpc_endpoint_ids
}

output "service_urls" {
  description = "HTTPS URLs keyed by application service."
  value = {
    for service_name, hostname in module.container_platform.service_hostnames :
    service_name => "https://${hostname}"
  }
}

output "service_container_images" {
  description = "Container image URIs keyed by application service."
  value       = module.container_platform.service_container_images
}

output "ecs_task_role_arns" {
  description = "IAM task role ARNs keyed by application service."
  value       = module.container_platform.ecs_task_role_arns
}

output "advisor_frontend_url" {
  description = "HTTPS URL for the Architecture Advisor frontend, or null when Advisor is disabled."
  value       = try(module.advisor_frontend["advisor"].frontend_url, null)
}

output "advisor_frontend_bucket_name" {
  description = "Name of the Architecture Advisor frontend S3 bucket, or null when Advisor is disabled."
  value       = try(module.advisor_frontend["advisor"].bucket_name, null)
}

output "advisor_frontend_cloudfront_distribution_id" {
  description = "Architecture Advisor CloudFront distribution ID, or null when Advisor is disabled."
  value       = try(module.advisor_frontend["advisor"].cloudfront_distribution_id, null)
}

output "advisor_frontend_cloudfront_domain_name" {
  description = "Architecture Advisor CloudFront domain name, or null when Advisor is disabled."
  value       = try(module.advisor_frontend["advisor"].cloudfront_domain_name, null)
}
