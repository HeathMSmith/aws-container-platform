variable "project_name" {
  description = "Name of the project used for observability resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "alb_arn" {
  description = "ARN of the shared Application Load Balancer to monitor."
  type        = string
}

variable "alb_5xx_alarm_threshold" {
  description = "Number of ALB-generated 5XX responses that triggers the ALB 5XX alarm."
  type        = number
  default     = 5
}

variable "alarm_action_arns" {
  description = "ARNs of actions invoked when a platform CloudWatch alarm enters the ALARM state."
  type        = list(string)
  default     = []
}
