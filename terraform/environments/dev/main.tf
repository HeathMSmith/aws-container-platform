data "aws_ecr_repository" "app" {
  name = var.project_name
}

module "container_platform" {
  source = "../../modules/container-platform"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  container_image       = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
  container_port        = var.container_port
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  desired_count         = var.desired_count
  log_retention_in_days = var.log_retention_in_days

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}
