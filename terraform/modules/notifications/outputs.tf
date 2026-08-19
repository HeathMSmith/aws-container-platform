output "topic_arn" {
  description = "ARN of the SNS topic used for platform alarm notifications."
  value       = aws_sns_topic.alarms.arn
}

output "topic_name" {
  description = "Name of the SNS topic used for platform alarm notifications."
  value       = aws_sns_topic.alarms.name
}
