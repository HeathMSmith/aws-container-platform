variable "project_name" {
  description = "Name of the container platform project."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "service_name" {
  description = "Logical name of the ECS application service."
  type        = string
}

variable "policy_json" {
  description = "Optional IAM policy JSON granting AWS API permissions to the application task role."
  type        = string
  default     = null
}