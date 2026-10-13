resource "aws_kms_key" "cloudops_key" {
  description             = "KMS key for CloudOps platform encryption (${var.environment})"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_kms_alias" "cloudops_alias" {
  name          = "alias/cloudops-${var.environment}"
  target_key_id = aws_kms_key.cloudops_key.key_id
}

output "kms_key_arn" {
  value = aws_kms_key.cloudops_key.arn
}
