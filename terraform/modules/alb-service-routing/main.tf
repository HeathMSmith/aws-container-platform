locals {
  service_name_prefix = "${var.project_name}-${var.environment}-${var.service_name}"

  # ALB target group names are limited to 32 characters. Preserve the
  # human-readable service name when it fits; otherwise use a deterministic
  # shortened name with a hash suffix to avoid collisions.
  target_group_name = length(local.service_name_prefix) <= 32 ? local.service_name_prefix : format(
    "%s-%s",
    substr(local.service_name_prefix, 0, 23),
    substr(sha1(local.service_name_prefix), 0, 8)
  )
}

resource "aws_lb_target_group" "app" {
  name        = local.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = local.service_name_prefix
  }
}

resource "aws_lb_listener_rule" "service" {
  listener_arn = var.https_listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  condition {
    host_header {
      values = [var.service_hostname]
    }
  }
}
