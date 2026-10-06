variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ALB resides"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public Subnet IDs across 2 AZs to attach to ALB"
}

variable "target_port" {
  type        = number
  description = "Port on which the EC2 container application listens"
  default     = 3000
}
