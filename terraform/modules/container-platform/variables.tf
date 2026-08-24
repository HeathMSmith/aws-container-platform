variable "project_name" {
  description = "Name of the container platform project."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "services" {
  description = "Application services deployed on the container platform."

  type = map(object({
    hostname                          = string
    container_image                   = string
    environment_variables             = optional(map(string), {})
    container_port                    = number
    task_cpu                          = number
    task_memory                       = number
    desired_count                     = number
    health_check_grace_period_seconds = number
    listener_rule_priority            = number
    autoscaling_min_capacity          = number
    autoscaling_max_capacity          = number
    autoscaling_cpu_target_value      = number
    autoscaling_scale_in_cooldown     = number
    autoscaling_scale_out_cooldown    = number
    log_retention_in_days             = number
  }))
}

variable "service_task_policy_json" {
  description = "Optional IAM policy JSON keyed by application service."
  type        = map(string)
  default     = {}
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate used for HTTPS traffic."
  type        = string
}

variable "hosted_zone_id" {
  description = "ID of the Route 53 hosted zone used for service DNS records."
  type        = string
}

variable "aws_region" {
  description = "AWS region in which the container platform is deployed."
  type        = string
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

variable "bedrock_runtime_endpoint_enabled" {
  description = "Whether to create a private Bedrock Runtime endpoint for the Advisor service."
  type        = bool
  default     = false

  validation {
    condition = (
      !var.bedrock_runtime_endpoint_enabled ||
      contains(keys(var.services), "advisor")
    )
    error_message = "The Advisor service must be deployed when the Bedrock Runtime endpoint is enabled."
  }
}

variable "bedrock_runtime_inference_profile_arn" {
  description = "Inference profile ARN allowed through the Bedrock Runtime endpoint."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      !var.bedrock_runtime_endpoint_enabled ||
      var.bedrock_runtime_inference_profile_arn != null
    )
    error_message = "bedrock_runtime_inference_profile_arn is required when the Bedrock Runtime endpoint is enabled."
  }
}

variable "bedrock_runtime_foundation_model_arns" {
  description = "Foundation model ARNs used by the allowed Bedrock inference profile."
  type        = list(string)
  default     = []

  validation {
    condition = (
      !var.bedrock_runtime_endpoint_enabled ||
      length(var.bedrock_runtime_foundation_model_arns) > 0
    )
    error_message = "bedrock_runtime_foundation_model_arns must not be empty when the Bedrock Runtime endpoint is enabled."
  }
}
