output "arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.app.arn
}

output "dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.app.dns_name
}

output "zone_id" {
  description = "Canonical hosted zone ID of the Application Load Balancer."
  value       = aws_lb.app.zone_id
}

output "target_group_arn" {
  description = "ARN of the Application Load Balancer target group."
  value       = aws_lb_target_group.app.arn
}
