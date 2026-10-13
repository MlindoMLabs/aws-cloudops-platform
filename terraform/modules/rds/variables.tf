variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID where RDS resources will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of isolated/private subnet IDs for the RDS Subnet Group"
  type        = list(string)
}

variable "ec2_security_group_id" {
  description = "Security Group ID of the EC2 instances allowed to access PostgreSQL"
  type        = string
}

variable "db_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "cloudops_db"
}

variable "db_username" {
  description = "Master username for PostgreSQL"
  type        = string
  default     = "cloudops_admin"
}

variable "db_password" {
  description = "Master password for PostgreSQL (sensitive)"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "Minimum allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit for storage autoscaling in GB"
  type        = number
  default     = 50
}

variable "instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is Multi-AZ"
  type        = bool
  default     = false
}
