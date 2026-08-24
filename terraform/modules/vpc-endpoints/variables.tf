variable "project_name" {
  description = "Name of the project used for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "aws_region" {
  description = "AWS region in which the VPC endpoints are deployed."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC in which the endpoints are created."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets used by interface VPC endpoints."
  type        = list(string)
}

variable "private_route_table_id" {
  description = "ID of the private route table associated with the S3 gateway endpoint."
  type        = string
}

variable "vpc_endpoint_security_group_id" {
  description = "ID of the security group attached to interface VPC endpoints."
  type        = string
}

variable "bedrock_runtime_endpoint_enabled" {
  description = "Whether to create a private Amazon Bedrock Runtime interface endpoint."
  type        = bool
  default     = false
}

variable "bedrock_runtime_principal_arn" {
  description = "IAM principal ARN allowed to invoke Amazon Bedrock through the endpoint."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      !var.bedrock_runtime_endpoint_enabled ||
      var.bedrock_runtime_principal_arn != null
    )
    error_message = "bedrock_runtime_principal_arn is required when the Bedrock Runtime endpoint is enabled."
  }
}

variable "bedrock_runtime_inference_profile_arn" {
  description = "Inference profile ARN allowed through the Amazon Bedrock Runtime endpoint."
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
  description = "Foundation model ARNs used by the allowed Amazon Bedrock inference profile."
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
