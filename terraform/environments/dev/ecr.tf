module "ecr" {
  source = "../../modules/ecr"

  repository_name = "aws-container-platform"
}
