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

moved {
  from = module.container_platform.module.ecs_services.aws_iam_role.ecs_task_execution
  to   = module.container_platform.module.ecs_task_execution.aws_iam_role.ecs_task_execution
}

moved {
  from = module.container_platform.module.ecs_services.aws_iam_role_policy_attachment.ecs_task_execution
  to   = module.container_platform.module.ecs_task_execution.aws_iam_role_policy_attachment.ecs_task_execution
}

moved {
  from = module.container_platform.module.observability.aws_cloudwatch_metric_alarm.alb_5xx
  to   = module.container_platform.module.platform_observability.aws_cloudwatch_metric_alarm.alb_5xx
}

moved {
  from = module.container_platform.module.alb_service_routing
  to   = module.container_platform.module.alb_service_routing["api"]
}

moved {
  from = module.container_platform.module.ecs_services
  to   = module.container_platform.module.ecs_services["api"]
}

moved {
  from = module.container_platform.module.ecs_autoscaling
  to   = module.container_platform.module.ecs_autoscaling["api"]
}

moved {
  from = module.container_platform.module.observability
  to   = module.container_platform.module.observability["api"]
}

moved {
  from = module.container_platform.module.dns
  to   = module.container_platform.module.dns["api"]
}
