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

output "https_listener_arn" {
  description = "ARN of the shared HTTPS listener."
  value       = aws_lb_listener.https.arn
}
