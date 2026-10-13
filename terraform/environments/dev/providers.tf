
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "cloudops-tfstate-039379078170"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cloudops-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-cloudops-platform"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
