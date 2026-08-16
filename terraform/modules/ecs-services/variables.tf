variable "project_name" {
  description = "Name of the project used for ECS resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "aws_region" {
  description = "AWS region in which ECS resources are deployed."
  type        = string
}

variable "container_image" {
  description = "Container image URI used by the ECS task definition."
  type        = string
}

variable "container_port" {
  description = "Port exposed by the application container."
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "CPU units allocated to the Fargate task."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory in MiB allocated to the Fargate task."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS service tasks."
  type        = number
  default     = 2
}

variable "log_retention_in_days" {
  description = "Number of days to retain ECS application logs in CloudWatch."
  type        = number
  default     = 7
}

variable "target_group_arn" {
  description = "ARN of the Application Load Balancer target group."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets in which ECS tasks are launched."
  type        = list(string)
}

variable "ecs_task_security_group_id" {
  description = "ID of the security group attached to ECS tasks."
  type        = string
}
