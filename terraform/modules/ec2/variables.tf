variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EC2 instances reside"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public Subnet IDs to place compute nodes"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance size (Free Tier eligible: t2.micro or t3.micro)"
  default     = "t3.micro"
}

variable "alb_security_group_id" {
  description = "Security Group ID of the Application Load Balancer"
  type        = string
}

variable "secrets_policy_arn" {
  description = "ARN of the Secrets Manager IAM Policy from the RDS module"
  type        = string
}

