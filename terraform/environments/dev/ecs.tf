module "ecs_services" {
  source = "../../modules/ecs-services"

  project_name = "aws-container-platform"
  environment  = var.environment
  aws_region   = var.aws_region

  container_image = "${module.ecr.repository_url}:v0.1.0"

  target_group_arn           = module.alb.target_group_arn
  private_subnet_ids         = module.network.private_subnet_ids
  ecs_task_security_group_id = module.network.ecs_task_security_group_id
}
