module "network" {
  source = "../../modules/network"

  project_name = "aws-container-platform"
  environment  = var.environment
  aws_region   = var.aws_region

  vpc_cidr = "10.20.0.0/16"
  public_subnet_cidrs = [
    "10.20.1.0/24",
    "10.20.2.0/24"
  ]
  private_subnet_cidrs = [
    "10.20.11.0/24",
    "10.20.12.0/24"
  ]
}

module "vpc_endpoints" {
  source = "../../modules/vpc-endpoints"

  project_name                   = "aws-container-platform"
  environment                    = var.environment
  aws_region                     = var.aws_region
  vpc_id                         = module.network.vpc_id
  private_subnet_ids             = module.network.private_subnet_ids
  private_route_table_id         = module.network.private_route_table_id
  vpc_endpoint_security_group_id = module.network.vpc_endpoint_security_group_id
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = "aws-container-platform"
}

module "alb" {
  source = "../../modules/alb"

  project_name          = "aws-container-platform"
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
}

module "ecs_services" {
  source = "../../modules/ecs-services"

  project_name = "aws-container-platform"
  environment  = var.environment
  aws_region   = var.aws_region

  container_image = "${module.ecr.repository_url}:${var.image_tag}"

  target_group_arn           = module.alb.target_group_arn
  private_subnet_ids         = module.network.private_subnet_ids
  ecs_task_security_group_id = module.network.ecs_task_security_group_id
}
