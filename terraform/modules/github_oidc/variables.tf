variable "github_repo" {
  description = "GitHub repository in format 'owner/repo' (e.g. 'username/aws-cloudops-platform')"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}
