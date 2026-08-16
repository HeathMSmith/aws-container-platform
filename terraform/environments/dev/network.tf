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
