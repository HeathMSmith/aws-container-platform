output "ecr_repository_name" {
  description = "Name of the ECR repository."
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_url" {
  description = "URL used to push and pull container images."
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository."
  value       = aws_ecr_repository.app.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.app.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = aws_ecs_cluster.app.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group used by ECS tasks."
  value       = aws_cloudwatch_log_group.app.name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the IAM role used by ECS to execute tasks."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition."
  value       = aws_ecs_task_definition.app.arn
}

output "vpc_id" {
  description = "ID of the VPC used by the container platform."
  value       = aws_vpc.app.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets used by the Application Load Balancer."
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "ecs_task_security_group_id" {
  description = "ID of the security group attached to ECS Fargate tasks."
  value       = aws_security_group.ecs_tasks.id
}

output "ecs_service_name" {
  description = "Name of the ECS service running the container platform."
  value       = aws_ecs_service.app.name
}

output "ecs_service_arn" {
  description = "ARN of the ECS service running the container platform."
  value       = aws_ecs_service.app.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.app.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.app.arn
}

output "private_subnet_ids" {
  description = "IDs of the private subnets used by ECS Fargate tasks."
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "private_route_table_id" {
  description = "ID of the route table associated with the private subnets."
  value       = aws_route_table.private.id
}

output "vpc_endpoint_ids" {
  description = "IDs of the VPC endpoints used for private AWS service connectivity."
  value = {
    ecr_api = aws_vpc_endpoint.ecr_api.id
    ecr_dkr = aws_vpc_endpoint.ecr_dkr.id
    logs    = aws_vpc_endpoint.logs.id
    s3      = aws_vpc_endpoint.s3.id
  }
}
