variable "project_name" {
  description = "Name of the container platform project."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
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
