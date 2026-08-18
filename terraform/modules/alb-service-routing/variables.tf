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

variable "vpc_id" {
  description = "ID of the VPC in which the target group is created."
  type        = string
}

variable "container_port" {
  description = "Port on which the application container receives traffic."
  type        = number
}

variable "https_listener_arn" {
  description = "ARN of the shared HTTPS listener."
  type        = string
}

variable "listener_rule_priority" {
  description = "Priority assigned to the service host-based HTTPS listener rule."
  type        = number
}
