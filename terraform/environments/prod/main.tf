data "aws_ecr_repository" "app" {
  for_each = var.ecr_repository_names

  name = each.value
}

data "aws_route53_zone" "site" {
  name         = var.hosted_zone_name
  private_zone = false
}

data "aws_acm_certificate" "service" {
  domain      = var.certificate_domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

module "container_platform" {
  source = "../../modules/container-platform"

  project_name = var.project_name
  environment  = var.environment

  services = {
    api = {
      hostname                          = var.service_hostname
      container_image                   = "${data.aws_ecr_repository.app["api"].repository_url}:${var.api_image_tag}"
      container_port                    = var.container_port
      task_cpu                          = var.task_cpu
      task_memory                       = var.task_memory
      desired_count                     = var.desired_count
      health_check_grace_period_seconds = 30
      listener_rule_priority            = 100
      autoscaling_min_capacity          = var.autoscaling_min_capacity
      autoscaling_max_capacity          = var.autoscaling_max_capacity
      autoscaling_cpu_target_value      = var.autoscaling_cpu_target_value
      autoscaling_scale_in_cooldown     = var.autoscaling_scale_in_cooldown
      autoscaling_scale_out_cooldown    = var.autoscaling_scale_out_cooldown
      log_retention_in_days             = var.log_retention_in_days
    }
    info = {
      hostname                          = "info.container.hmsdev.click"
      container_image                   = "${data.aws_ecr_repository.app["info"].repository_url}:${var.info_image_tag}"
      container_port                    = var.container_port
      task_cpu                          = var.task_cpu
      task_memory                       = var.task_memory
      desired_count                     = var.desired_count
      health_check_grace_period_seconds = 30
      listener_rule_priority            = 110
      autoscaling_min_capacity          = var.autoscaling_min_capacity
      autoscaling_max_capacity          = var.autoscaling_max_capacity
      autoscaling_cpu_target_value      = var.autoscaling_cpu_target_value
      autoscaling_scale_in_cooldown     = var.autoscaling_scale_in_cooldown
      autoscaling_scale_out_cooldown    = var.autoscaling_scale_out_cooldown
      log_retention_in_days             = var.log_retention_in_days
    }
  }

  certificate_arn = data.aws_acm_certificate.service.arn
  hosted_zone_id  = data.aws_route53_zone.site.zone_id
  aws_region      = var.aws_region

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

resource "aws_sns_topic_subscription" "alarm_email" {
  count = var.alarm_notification_email != null ? 1 : 0

  topic_arn = module.container_platform.alarm_topic_arn
  protocol  = "email"
  endpoint  = var.alarm_notification_email
}
