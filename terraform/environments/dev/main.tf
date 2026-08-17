module "network" {
  source = "../../modules/network"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "vpc_endpoints" {
  source = "../../modules/vpc-endpoints"

  project_name                   = var.project_name
  environment                    = var.environment
  aws_region                     = var.aws_region
  vpc_id                         = module.network.vpc_id
  private_subnet_ids             = module.network.private_subnet_ids
  private_route_table_id         = module.network.private_route_table_id
  vpc_endpoint_security_group_id = module.network.vpc_endpoint_security_group_id
}

data "aws_ecr_repository" "app" {
  name = var.project_name
}

module "alb" {
  source = "../../modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
}

module "ecs_services" {
  source = "../../modules/ecs-services"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  container_image = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"

  target_group_arn           = module.alb.target_group_arn
  private_subnet_ids         = module.network.private_subnet_ids
  ecs_task_security_group_id = module.network.ecs_task_security_group_id
}

module "observability" {
  source = "../../modules/observability"

  project_name     = var.project_name
  environment      = var.environment
  ecs_cluster_name = module.ecs_services.cluster_name
  ecs_service_name = module.ecs_services.service_name
  alb_arn          = module.alb.arn
  target_group_arn = module.alb.target_group_arn
}
