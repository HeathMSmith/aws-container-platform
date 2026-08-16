output "ecr_repository_name" {
  description = "Name of the persistent ECR repository."
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "URL used to push and pull container images."
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the persistent ECR repository."
  value       = module.ecr.repository_arn
}
