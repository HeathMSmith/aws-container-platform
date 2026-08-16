variable "project_name" {
  description = "Name of the project used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC in which the target group is created."
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets used by the Application Load Balancer."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID of the security group attached to the Application Load Balancer."
  type        = string
}
