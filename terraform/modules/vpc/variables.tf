variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (2 AZs)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private app subnets (2 AZs)"
}

variable "database_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for isolated DB subnets (2 AZs)"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to distribute subnets"
  default     = ["us-east-1a", "us-east-1b"]
}
