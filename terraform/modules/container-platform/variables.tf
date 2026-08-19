variable "project_name" {
  description = "Name of the container platform project."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "services" {
  description = "Application services deployed on the container platform."

  type = map(object({
    hostname                          = string
    container_image                   = string
    container_port                    = number
    task_cpu                          = number
    task_memory                       = number
    desired_count                     = number
    health_check_grace_period_seconds = number
    listener_rule_priority            = number
    autoscaling_min_capacity          = number
    autoscaling_max_capacity          = number
    autoscaling_cpu_target_value      = number
    autoscaling_scale_in_cooldown     = number
    autoscaling_scale_out_cooldown    = number
    log_retention_in_days             = number
  }))
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate used for HTTPS traffic."
  type        = string
}

variable "hosted_zone_id" {
  description = "ID of the Route 53 hosted zone used for service DNS records."
  type        = string
}

variable "aws_region" {
  description = "AWS region in which the container platform is deployed."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the platform VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to the public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to the private subnets."
  type        = list(string)
}
