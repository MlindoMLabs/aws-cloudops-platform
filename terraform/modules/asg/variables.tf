variable "environment" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_security_group_id" {
  type = string
}

variable "iam_instance_profile_name" {
  type    = string
  default = ""
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_target_group_arn" {
  type = string
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "desired_capacity" {
  type    = number
  default = 2
}
