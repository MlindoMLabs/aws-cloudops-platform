output "trail_id" {
  value       = aws_cloudtrail.main.id
  description = "CloudTrail trail identifier"
}

output "audit_bucket_name" {
  value       = aws_s3_bucket.audit_logs.id
  description = "S3 bucket storing audit log records"
}
