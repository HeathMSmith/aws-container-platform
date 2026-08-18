variable "project_name" {
  description = "Name of the container platform project."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "service_name" {
  description = "Logical name of the application service deployed on the container platform."
  type        = string
}

variable "service_hostname" {
  description = "Hostname used to route external traffic to the application service."
  type        = string
}

variable "aws_region" {
  description = "AWS region in which the container platform is deployed."
  type        = string
}

variable "container_image" {
  description = "Container image URI deployed by the platform."
  type        = string
}

variable "container_port" {
  description = "Port exposed by the application container."
  type        = number
}

variable "task_cpu" {
  description = "CPU units allocated to the application task."
  type        = number
}

variable "task_memory" {
  description = "Memory in MiB allocated to the application task."
  type        = number
}

variable "desired_count" {
  description = "Desired number of application tasks."
  type        = number
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of ECS tasks maintained by Application Auto Scaling."
  type        = number
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of ECS tasks allowed by Application Auto Scaling."
  type        = number
}

variable "autoscaling_cpu_target_value" {
  description = "Average ECS service CPU utilization percentage targeted by Application Auto Scaling."
  type        = number
}

variable "autoscaling_scale_in_cooldown" {
  description = "Number of seconds Application Auto Scaling waits after a scale-in activity before another scale-in activity."
  type        = number
}

variable "autoscaling_scale_out_cooldown" {
  description = "Number of seconds Application Auto Scaling waits after a scale-out activity before another scale-out activity."
  type        = number
}

variable "log_retention_in_days" {
  description = "Number of days to retain application logs in CloudWatch."
  type        = number
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
