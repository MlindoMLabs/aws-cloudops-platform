variable "environment" {
  type        = string
  description = "Deployment environment name"
}

variable "db_host" {
  type        = string
  description = "RDS database endpoint address"
}

variable "db_port" {
  type        = number
  default     = 5432
  description = "RDS database port"
}

variable "db_name" {
  type        = string
  description = "Initial database name"
}

variable "db_username" {
  type        = string
  description = "Database master username"
}
