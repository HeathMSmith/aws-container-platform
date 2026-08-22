variable "project_name" {
  description = "Name of the project used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "frontend_hostname" {
  description = "DNS hostname used to access the static frontend."
  type        = string
}

variable "hosted_zone_id" {
  description = "Route 53 hosted zone ID used for the frontend DNS records."
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN used by the CloudFront distribution."
  type        = string
}

variable "site_source_path" {
  description = "Path to the local static frontend source files."
  type        = string
}

variable "api_url" {
  description = "API URL written to the frontend runtime configuration."
  type        = string
}
