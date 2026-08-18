variable "project_name" {
  description = "Name of the project used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "service_hostname" {
  description = "Hostname used to route external traffic to the application service."
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate used by the HTTPS listener."
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

variable "container_port" {
  description = "Port on which the application container receives traffic from the Application Load Balancer."
  type        = number
}
