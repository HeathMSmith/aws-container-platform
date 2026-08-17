variable "project_name" {
  description = "Name of the project used for observability resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to monitor."
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service to monitor."
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer to monitor."
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the Application Load Balancer target group to monitor."
  type        = string
}

variable "cpu_alarm_threshold" {
  description = "ECS CPU utilization percentage that triggers the high CPU alarm."
  type        = number
  default     = 80
}

variable "memory_alarm_threshold" {
  description = "ECS memory utilization percentage that triggers the high memory alarm."
  type        = number
  default     = 80
}

variable "alb_5xx_alarm_threshold" {
  description = "Number of ALB-generated 5XX responses that triggers the ALB 5XX alarm."
  type        = number
  default     = 5
}

variable "target_5xx_alarm_threshold" {
  description = "Number of target-generated 5XX responses that triggers the target 5XX alarm."
  type        = number
  default     = 5
}

variable "unhealthy_host_alarm_threshold" {
  description = "Number of unhealthy targets that triggers the unhealthy host alarm."
  type        = number
  default     = 1
}
