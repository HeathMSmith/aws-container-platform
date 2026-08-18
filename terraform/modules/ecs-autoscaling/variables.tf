variable "project_name" {
  description = "Name of the project used for ECS autoscaling resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster containing the scalable service."
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service managed by Application Auto Scaling."
  type        = string
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks maintained by Application Auto Scaling."
  type        = number
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks allowed by Application Auto Scaling."
  type        = number
}

variable "cpu_target_value" {
  description = "Average ECS service CPU utilization percentage targeted by the scaling policy."
  type        = number
}

variable "scale_in_cooldown" {
  description = "Number of seconds Application Auto Scaling waits after a scale-in activity before another scale-in activity."
  type        = number
}

variable "scale_out_cooldown" {
  description = "Number of seconds Application Auto Scaling waits after a scale-out activity before another scale-out activity."
  type        = number
}
