data "aws_ecr_repository" "app" {
  name = var.project_name
}

data "aws_route53_zone" "site" {
  name         = var.hosted_zone_name
  private_zone = false
}

module "container_platform" {
  source = "../../modules/container-platform"

  project_name     = var.project_name
  environment      = var.environment
  service_name     = var.service_name
  service_hostname = var.service_hostname
  hosted_zone_id   = data.aws_route53_zone.site.zone_id
  aws_region       = var.aws_region

  container_image                = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
  container_port                 = var.container_port
  task_cpu                       = var.task_cpu
  task_memory                    = var.task_memory
  desired_count                  = var.desired_count
  autoscaling_min_capacity       = var.autoscaling_min_capacity
  autoscaling_max_capacity       = var.autoscaling_max_capacity
  autoscaling_cpu_target_value   = var.autoscaling_cpu_target_value
  autoscaling_scale_in_cooldown  = var.autoscaling_scale_in_cooldown
  autoscaling_scale_out_cooldown = var.autoscaling_scale_out_cooldown
  log_retention_in_days          = var.log_retention_in_days

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}
