locals {
  repositories = {
    legacy  = "aws-container-platform"
    api     = "aws-container-platform-api"
    info    = "aws-container-platform-info"
    advisor = "aws-container-platform-advisor"
  }
}

module "ecr" {
  for_each = local.repositories

  source = "../../modules/ecr"

  repository_name = each.value
}
