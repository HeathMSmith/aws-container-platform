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
  certificate_arn       = var.certificate_arn
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
}

module "alb_service_routing" {
  source   = "../alb-service-routing"
  for_each = var.services

  project_name     = var.project_name
  environment      = var.environment
  service_name     = each.key
  service_hostname = each.value.hostname

  vpc_id                 = module.network.vpc_id
  container_port         = each.value.container_port
  https_listener_arn     = module.alb.https_listener_arn
  listener_rule_priority = each.value.listener_rule_priority
}

module "dns" {
  source   = "../dns"
  for_each = var.services

  hosted_zone_id   = var.hosted_zone_id
  service_hostname = each.value.hostname

  alb_dns_name = module.alb.dns_name
  alb_zone_id  = module.alb.zone_id
}

module "ecs_cluster" {
  source = "../ecs-cluster"

  project_name = var.project_name
  environment  = var.environment
}

module "ecs_task_execution" {
  source = "../ecs-task-execution"

  project_name = var.project_name
  environment  = var.environment
}

module "ecs_task_role" {
  source   = "../ecs-task-role"
  for_each = var.services

  project_name = var.project_name
  environment  = var.environment
  service_name = each.key
  policy_json  = lookup(var.service_task_policy_json, each.key, null)
}

module "ecs_services" {
  source   = "../ecs-services"
  for_each = var.services

  project_name = var.project_name
  environment  = var.environment
  service_name = each.key
  aws_region   = var.aws_region

  container_image         = each.value.container_image
  environment_variables   = each.value.environment_variables
  container_port          = each.value.container_port
  task_cpu                = each.value.task_cpu
  task_memory             = each.value.task_memory
  task_execution_role_arn = module.ecs_task_execution.role_arn
  task_role_arn           = module.ecs_task_role[each.key].role_arn

  desired_count                     = each.value.desired_count
  health_check_grace_period_seconds = each.value.health_check_grace_period_seconds
  log_retention_in_days             = each.value.log_retention_in_days

  target_group_arn           = module.alb_service_routing[each.key].target_group_arn
  private_subnet_ids         = module.network.private_subnet_ids
  ecs_task_security_group_id = module.network.ecs_task_security_group_id
  ecs_cluster_id             = module.ecs_cluster.cluster_id
}

module "ecs_autoscaling" {
  source   = "../ecs-autoscaling"
  for_each = var.services

  project_name = var.project_name
  environment  = var.environment
  service_name = each.key

  ecs_cluster_name = module.ecs_cluster.cluster_name
  ecs_service_name = module.ecs_services[each.key].service_name

  min_capacity       = each.value.autoscaling_min_capacity
  max_capacity       = each.value.autoscaling_max_capacity
  cpu_target_value   = each.value.autoscaling_cpu_target_value
  scale_in_cooldown  = each.value.autoscaling_scale_in_cooldown
  scale_out_cooldown = each.value.autoscaling_scale_out_cooldown
}

module "platform_observability" {
  source = "../platform-observability"

  project_name      = var.project_name
  environment       = var.environment
  alb_arn           = module.alb.arn
  alarm_action_arns = [module.notifications.topic_arn]
}

module "observability" {
  source   = "../observability"
  for_each = var.services

  project_name      = var.project_name
  environment       = var.environment
  service_name      = each.key
  ecs_cluster_name  = module.ecs_cluster.cluster_name
  ecs_service_name  = module.ecs_services[each.key].service_name
  alb_arn           = module.alb.arn
  target_group_arn  = module.alb_service_routing[each.key].target_group_arn
  alarm_action_arns = [module.notifications.topic_arn]
}

module "notifications" {
  source = "../notifications"

  project_name = var.project_name
  environment  = var.environment
}
