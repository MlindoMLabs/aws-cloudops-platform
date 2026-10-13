# 1. Generate a secure random password for PostgreSQL
resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 2. Store Database Credentials in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.environment}/rds/postgres-credentials"
  description             = "Master PostgreSQL database credentials managed by Terraform"
  recovery_window_in_days = 0 # Immediate deletion for dev teardowns; set to 30+ in production

  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials_val" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    engine   = "postgres"
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
    username = var.db_username
    password = random_password.db_password.result
  })

  lifecycle {
    ignore_changes = [
      secret_string, # Ignore external rotations done by Lambda/manual updates
    ]
  }
}
