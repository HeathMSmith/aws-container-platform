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
