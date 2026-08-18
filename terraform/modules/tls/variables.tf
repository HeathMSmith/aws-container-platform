variable "certificate_domain_name" {
  description = "Domain name for the ACM certificate used by container platform services."
  type        = string
}

variable "hosted_zone_id" {
  description = "ID of the Route 53 hosted zone used for ACM DNS validation."
  type        = string
}