output "ecr_repository_names" {
  description = "Names of the persistent ECR repositories keyed by service."
  value = {
    for key, repository in module.ecr :
    key => repository.repository_name
  }
}

output "ecr_repository_urls" {
  description = "URLs of the persistent ECR repositories keyed by service."
  value = {
    for key, repository in module.ecr :
    key => repository.repository_url
  }
}

output "ecr_repository_arns" {
  description = "ARNs of the persistent ECR repositories keyed by service."
  value = {
    for key, repository in module.ecr :
    key => repository.repository_arn
  }
}
