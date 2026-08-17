module "network" {
  source = "../network"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "vpc_endpoints" {
  source = "../vpc-endpoints"

  project_name                   = var.project_name
  environment                    = var.environment
  aws_region                     = var.aws_region
  vpc_id                         = module.network.vpc_id
  private_subnet_ids             = module.network.private_subnet_ids
  private_route_table_id         = module.network.private_route_table_id
  vpc_endpoint_security_group_id = module.network.vpc_endpoint_security_group_id
}

module "alb" {
  source = "../alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
}

module "ecs_cluster" {
  source = "../ecs-cluster"

  project_name = var.project_name
  environment  = var.environment
}

module "ecs_services" {
  source = "../ecs-services"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  container_image       = var.container_image
  container_port        = var.container_port
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  desired_count         = var.desired_count
  log_retention_in_days = var.log_retention_in_days

  target_group_arn           = module.alb.target_group_arn
  private_subnet_ids         = module.network.private_subnet_ids
  ecs_task_security_group_id = module.network.ecs_task_security_group_id
  ecs_cluster_id             = module.ecs_cluster.cluster_id
}

module "observability" {
  source = "../observability"

  project_name     = var.project_name
  environment      = var.environment
  ecs_cluster_name = module.ecs_cluster.cluster_name
  ecs_service_name = module.ecs_services.service_name
  alb_arn          = module.alb.arn
  target_group_arn = module.alb.target_group_arn
}
