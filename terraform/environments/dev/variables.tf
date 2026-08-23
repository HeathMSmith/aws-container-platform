variable "project_name" {
  description = "Name of the container platform project."
  type        = string
  default     = "aws-container-platform"
}

variable "ecr_repository_names" {
  description = "ECR repository names keyed by application service."
  type        = map(string)

  default = {
    api     = "aws-container-platform-api"
    info    = "aws-container-platform-info"
    advisor = "aws-container-platform-advisor"
  }
}

variable "enabled_services" {
  description = "Application services enabled for deployment in this environment."
  type        = set(string)

  default = [
    "api",
    "info",
    "advisor",
  ]

  validation {
    condition = alltrue([
      for service in var.enabled_services :
      contains(["api", "info", "advisor"], service)
    ])

    error_message = "enabled_services may contain only: api, info, advisor."
  }
}

variable "aws_region" {
  description = "AWS region in which to deploy the container platform resources."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either dev or prod."
  }
}

variable "service_name" {
  description = "Logical name of the application service deployed on the container platform."
  type        = string
  default     = "api"
}

variable "service_hostname" {
  description = "Hostname used to route external traffic to the application service."
  type        = string
  default     = "api-dev.container.hmsdev.click"
}

variable "hosted_zone_name" {
  description = "Name of the existing public Route 53 hosted zone used for service DNS records."
  type        = string
  default     = "hmsdev.click"
}

variable "certificate_domain_name" {
  description = "Domain name for the ACM certificate used by container platform services."
  type        = string
  default     = "*.container.hmsdev.click"
}

variable "api_image_tag" {
  description = "Immutable ECR image tag deployed to the API service."
  type        = string
  default     = "v0.1.1-fastapi-health-api"
}

variable "info_image_tag" {
  description = "Immutable ECR image tag deployed to the INFO service."
  type        = string
  default     = "v0.1.1-fastapi-info-api"
}

variable "advisor_image_tag" {
  description = "Immutable ECR image tag deployed to the architecture advisor service."
  type        = string
  default     = "v0.1.3-architecture-advisor"
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the environment VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to the public subnets."
  type        = list(string)
  default = [
    "10.20.1.0/24",
    "10.20.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to the private subnets."
  type        = list(string)
  default = [
    "10.20.11.0/24",
    "10.20.12.0/24"
  ]
}

variable "container_port" {
  description = "Port exposed by the application container."
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "CPU units allocated to the application task."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory in MiB allocated to the application task."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of application tasks."
  type        = number
  default     = 2
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of ECS tasks maintained by Application Auto Scaling."
  type        = number
  default     = 2
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of ECS tasks allowed by Application Auto Scaling."
  type        = number
  default     = 4
}

variable "autoscaling_cpu_target_value" {
  description = "Average ECS service CPU utilization percentage targeted by Application Auto Scaling."
  type        = number
  default     = 60
}

variable "autoscaling_scale_in_cooldown" {
  description = "Number of seconds Application Auto Scaling waits after a scale-in activity before another scale-in activity."
  type        = number
  default     = 300
}

variable "autoscaling_scale_out_cooldown" {
  description = "Number of seconds Application Auto Scaling waits after a scale-out activity before another scale-out activity."
  type        = number
  default     = 60
}

variable "log_retention_in_days" {
  description = "Number of days to retain application logs in CloudWatch."
  type        = number
  default     = 7
}

variable "alarm_notification_email" {
  description = "Email address subscribed to DEV platform alarm notifications."
  type        = string
  default     = null
  nullable    = true
}

variable "advisor_frontend_hostname" {
  description = "Hostname used to access the Architecture Advisor frontend."
  type        = string
  default     = "advisor-dev.hmsdev.click"
}
