variable "project_name" {
  description = "Name of the container platform project."
  type        = string
  default     = "aws-container-platform"
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

variable "image_tag" {
  description = "Immutable ECR image tag to deploy to the ECS service."
  type        = string
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

variable "log_retention_in_days" {
  description = "Number of days to retain application logs in CloudWatch."
  type        = number
  default     = 7
}
