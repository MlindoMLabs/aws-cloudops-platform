output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.this.port
}

output "db_security_group_id" {
  description = "Security Group ID associated with the RDS instance"
  value       = aws_security_group.rds.id
}

output "secrets_policy_arn" {
  description = "ARN of the Secrets Manager IAM Policy"
  value       = aws_iam_policy.secrets_access.arn
}
