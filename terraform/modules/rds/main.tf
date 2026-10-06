# 1. DB Subnet Group across isolated subnets
resource "aws_db_subnet_group" "this" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.environment}-rds-subnet-group"
    Environment = var.environment
  }
}

# 2. Security Group for RDS (Restricted ingress to EC2 SG only)
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Allow PostgreSQL inbound traffic from EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL access from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    ="-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
  }
}

# 3. Custom DB Parameter Group (Enforce UTF-8 and SSL connections)
resource "aws_db_parameter_group" "this" {
  name   = "${var.environment}-postgres16-pg"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "client_encoding"
    value = "UTF8"
  }

  tags = {
    Name        = "${var.environment}-postgres16-pg"
    Environment = var.environment
  }
}

# 4. RDS PostgreSQL Instance
resource "aws_db_instance" "this" {
  identifier     = "${var.environment}-cloudops-postgres"
  engine         = "postgres"
  engine_version = "16.1"

  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.this.name

  publicly_accessible = false
  multi_az            = var.multi_az
  skip_final_snapshot = true # Set to false for production setups

  backup_retention_period   = 7
  backup_window             = "03:00-04:00"
  maintenance_window        = "Mon:04:30-Mon:05:30"
  auto_minor_version_upgrade = true

  deletion_protection = false

  tags = {
    Name        = "${var.environment}-cloudops-postgres"
    Environment = var.environment
  }
}


# Create the Secrets Manager secret container
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "cloudops/rds/postgres-credentials"
  description = "PostgreSQL credentials for Node.js backend application"

  tags = {
    Environment = "production"
    Project     = "aws-cloudops-platform"
  }
}

# Store the credential key-value pairs as JSON
resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    engine   = "postgres"
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = aws_db_instance.this.db_name
    username = aws_db_instance.this.username
    password = aws_db_instance.this.password
  })
}

# IAM Policy allowing read access to the specific secret
resource "aws_iam_policy" "secretsmanager_read" {
  name        = "SecretsManagerRDSReadPolicy"
  description = "Allows EC2 instances to fetch RDS credentials from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = aws_secretsmanager_secret.db_credentials.arn
      }
    ]
  })
}


resource "aws_iam_policy" "secrets_access" {
  name        = "cloudops-${var.environment}-rds-secrets-policy"
  description = "Allows access to RDS database credentials in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = aws_secretsmanager_secret.db_credentials.arn
      }
    ]
  })
}
