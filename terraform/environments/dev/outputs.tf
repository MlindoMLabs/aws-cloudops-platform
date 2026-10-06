output "region" {
  description = "Active AWS Deployment Region"
  value       = var.aws_region
}

output "environment" {
  description = "Deployment Envirnment Name"
  value       = var.environment
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  value = module.vpc.database_subnet_ids
}

output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "alb_dns_name" {
  description = "Public ALB URL to reach Node.js service"
  value       = module.alb.alb_dns_name
}

output "s3_app_storage_bucket" {
  value       = module.app_storage.bucket_id
  description = "Application storage S3 bucket name"
}

output "github_actions_role_arn" {
  value       = module.github_oidc.role_arn
  description = "Role ARN to configure in GitHub Secrets"
}
