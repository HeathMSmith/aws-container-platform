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
