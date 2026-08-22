output "bucket_name" {
  description = "Name of the S3 bucket containing the static frontend assets."
  value       = aws_s3_bucket.frontend.bucket
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution serving the static frontend."
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution serving the static frontend."
  value       = aws_cloudfront_distribution.frontend.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront-assigned domain name for the static frontend."
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "frontend_hostname" {
  description = "DNS hostname configured for the static frontend."
  value       = var.frontend_hostname
}

output "frontend_url" {
  description = "HTTPS URL for the static frontend."
  value       = "https://${var.frontend_hostname}"
}
