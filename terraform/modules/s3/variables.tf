variable "bucket_name" {
  description = "Unique name for the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable object versioning"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow bucket deletion even if non-empty (useful for dev/test teardowns)"
  type        = bool
  default     = false
}
