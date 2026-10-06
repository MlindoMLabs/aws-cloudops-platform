variable "aws_region" {
  type        = string
  description = "AWS Deployment Region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment Environment"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "Base CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets across AZs"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private app subnets across AZs"
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "database_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for isolated DB subnets across AZs"
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "db_password" {
  description = "Master password for the PostgreSQL RDS instance"
  type        = string
  sensitive   = true
}

variable "ami_id" {
  description = "AMI ID for the EC2 launch template"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Replace with your target region's Ubuntu/Amazon Linux 2023 AMI
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
