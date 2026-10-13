variable "environment" {
  type        = string
  description = "Deployment environment name"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "log_retention_days" {
  type        = number
  default     = 30
  description = "Log retention period in days"
}

variable "asg_name" {
  type        = string
  description = "Auto Scaling Group name to monitor"
}

variable "db_instance_id" {
  type        = string
  description = "RDS DB instance identifier to monitor"
}
