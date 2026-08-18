variable "hosted_zone_id" {
  description = "ID of the Route 53 hosted zone in which the service DNS record is created."
  type        = string
}

variable "service_hostname" {
  description = "Fully qualified hostname used to access the application service."
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  type        = string
}

variable "alb_zone_id" {
  description = "Canonical hosted zone ID of the Application Load Balancer."
  type        = string
}
