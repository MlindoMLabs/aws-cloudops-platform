# Main entrypoint for Dev Environment
# Infrastucture module will be declared here starting in step 8

locals {
  name_prefix = "cloudops-${var.environment}"
}

# VPC Model
module "vpc" {
  source = "../../modules/vpc"

  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
}

# EC2 Application Module
module "ec2" {
  source = "../../modules/ec2"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_type     = "t3.micro"

  # Pass cross-module references here at top level
  alb_security_group_id = module.alb.alb_security_group_id
  secrets_policy_arn    = module.rds.secrets_policy_arn

  # ... other variables ...
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ec2_security_group_id = module.ec2.security_group_id

  db_name     = "cloudops_db"
  db_username = "cloudops_admin"
  db_password = var.db_password # Injected via terraform.tfvars or environment variable
}

# Instantiate ALB Module
module "alb" {
  source = "../../modules/alb"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  target_port       = 3000
}

# Attach EC2 App Host to Target Group
resource "aws_lb_target_group_attachment" "app_ec2" {
  target_group_arn = module.alb.target_group_arn
  target_id        = module.ec2.instance_id
  port             = 3000
}

module "asg" {
  source = "../../modules/asg"

  environment               = var.environment
  ami_id                    = var.ami_id
  instance_type             = var.instance_type
  private_subnet_ids        = module.vpc.private_subnet_ids
  ec2_security_group_id     = module.ec2.security_group_id
  alb_target_group_arn      = module.alb.target_group_arn
  iam_instance_profile_name = module.ec2.iam_instance_profile_name

  min_size         = 1
  max_size         = 3
  desired_capacity = 2
}

module "app_storage" {
  source = "../../modules/s3"

  bucket_name        = "aws-cloudops-platform-storage-dev-${var.environment}"
  environment        = var.environment
  versioning_enabled = true
  force_destroy      = true # Set to true for dev cleanup convenience
}

module "github_oidc" {
  source      = "../../modules/github_oidc"
  environment = var.environment
  github_repo = var.github_repo # Passes variable from environment root
}

module "cloudwatch" {
  source             = "../../modules/cloudwatch"
  environment        = var.environment
  aws_region         = var.aws_region
  log_retention_days = 14
  asg_name           = module.asg.asg_name
  db_instance_id     = module.rds.db_instance_id
}

module "cloudtrail" {
  source      = "../../modules/cloudtrail"
  environment = var.environment
}

module "secrets" {
  source      = "../../modules/secrets"
  environment = var.environment
  db_host     = module.rds.db_instance_endpoint
  db_port     = 5432
  db_name     = "cloudops_db"
  db_username = "cloudops_user"
}
