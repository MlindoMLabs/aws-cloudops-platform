data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# 1. S3 Bucket for CloudTrail Logs
resource "aws_s3_bucket" "audit_logs" {
  bucket        = "cloudops-audit-logs-${data.aws_caller_identity.current.account_id}-${var.environment}"
  force_destroy = true # Convenient for dev/test environments

  tags = {
    Name        = "cloudops-audit-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit_logs" {
  bucket = aws_s3_bucket.audit_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "audit_logs" {
  bucket                  = aws_s3_bucket.audit_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. S3 Bucket Policy allowing CloudTrail to write logs
resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.audit_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.audit_logs.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.audit_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# 3. CloudTrail Trail
resource "aws_cloudtrail" "main" {
  name                          = "cloudops-audit-trail-${var.environment}"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true # Ensures log files haven't been tampered with

  depends_on = [aws_s3_bucket_policy.cloudtrail_bucket_policy]

  tags = {
    Environment = var.environment
  }
}
