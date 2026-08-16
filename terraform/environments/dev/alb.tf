module "alb" {
  source = "../../modules/alb"

  project_name          = "aws-container-platform"
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
}
