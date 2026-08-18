output "target_group_arn" {
  description = "ARN of the target group used by the application service."
  value       = aws_lb_target_group.app.arn
}
