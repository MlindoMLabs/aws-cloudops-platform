output "secret_arn" {
  value       = aws_secretsmanager_secret.db_credentials.arn
  description = "ARN of the Secrets Manager secret"
}

output "secret_name" {
  value       = aws_secretsmanager_secret.db_credentials.name
  description = "Name of the Secrets Manager secret"
}
