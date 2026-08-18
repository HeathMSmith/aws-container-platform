moved {
  from = module.network
  to   = module.container_platform.module.network
}

moved {
  from = module.vpc_endpoints
  to   = module.container_platform.module.vpc_endpoints
}

moved {
  from = module.alb
  to   = module.container_platform.module.alb
}

moved {
  from = module.ecs_cluster
  to   = module.container_platform.module.ecs_cluster
}

moved {
  from = module.ecs_services
  to   = module.container_platform.module.ecs_services
}

moved {
  from = module.observability
  to   = module.container_platform.module.observability
}

moved {
  from = module.container_platform.module.alb.aws_lb_target_group.app
  to   = module.container_platform.module.alb_service_routing.aws_lb_target_group.app
}

moved {
  from = module.container_platform.module.alb.aws_lb_listener_rule.service
  to   = module.container_platform.module.alb_service_routing.aws_lb_listener_rule.service
}
