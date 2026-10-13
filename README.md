# 🚀 AWS CloudOps Production Platform

[![CI Pipeline](https://github.com/YOUR_GITHUB_USERNAME/aws-cloudops-platform/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_GITHUB_USERNAME/aws-cloudops-platform/actions/workflows/ci.yml)
[![CD Pipeline](https://github.com/YOUR_GITHUB_USERNAME/aws-cloudops-platform/actions/workflows/cd.yml/badge.svg)](https://github.com/YOUR_GITHUB_USERNAME/aws-cloudops-platform/actions/workflows/cd.yml)
[![Terraform](https://img.shields.io/badge/Terraform-1.5%2B-purple?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-CloudOps-orange?logo=amazon-aws)](https://aws.amazon.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An enterprise-grade, highly available, and secure multi-tier web application platform provisioned entirely via **Terraform (IaC)**, containerized with **Docker**, and automated using **GitHub Actions OIDC CI/CD pipelines**.

---

## 🏛️ Architecture Overview

The platform deploys a secure 3-tier web architecture across multiple availability zones in AWS (`us-east-1`):

* **Public Tier**: Internet-facing Application Load Balancer (ALB) distributing traffic securely across EC2 instances.
* **Private Compute Tier**: Auto Scaling Group (ASG) running containerized Node.js microservices behind the ALB.
* **Private Database Tier**: Multi-AZ RDS PostgreSQL instance isolated from direct public access, communicating solely with the application security group.
* **Security & Governance**: AWS Secrets Manager for credential management, CloudWatch for central logging/alarms, CloudTrail for API auditing, and Customer-Managed KMS Keys for encryption.

<<<<<<< HEAD


=======
>>>>>>> develop
* Internet
                 │
                 ▼
         ┌─────────────────┐
         │ Application     │
         │ Load Balancer   │
         └────────┬────────┘
                  │
         ┌────────┴────────┐
         ▼                 ▼
    ┌──────────┐      ┌──────────┐
    │ EC2 #1   │      │ EC2 #2   │
    │ Docker   │      │ Docker   │
    └────┬─────┘      └────┬─────┘
         │                 │
         └────────┬────────┘
                  ▼
           ┌─────────────┐
           │ RDS         │
           │ PostgreSQL  │
           └─────────────┘
---

<<<<<<< HEAD

=======
>>>>>>> develop
## 📂 Project Structure

```tree
aws-cloudops-platform/
├── app/
│   ├── backend/             # Node.js Express REST API & Task module
│   └── frontend/            # React SPA interface
├── terraform/
│   ├── environments/dev/    # Dev environment runner configuration
│   └── modules/             # Reusable modules (vpc, ec2, alb, rds, asg, s3, iam, cloudwatch, cloudtrail, security, github_oidc)
├── docker/                  # Local docker-compose stack
├── scripts/                 # Deployment, health check, and cleanup automation
├── .github/workflows/       # CI and CD pipelines (OIDC authentication)
└── docs/                    # Detailed architecture, security, monitoring, and troubleshooting guides


🛠️ Tech Stack & Tooling

    Infrastructure as Code: Terraform (S3 Remote State + DynamoDB State Locking)
    Compute & Containerization: AWS EC2, Auto Scaling Groups, Docker, Docker Compose, Multi-stage builds
    Networking & Load Balancing: VPC (Public/Private Subnets), Internet & NAT Gateways, ALB
    Database: Amazon RDS PostgreSQL (encrypted with KMS, secure secret rotation)
    Security & Auditing: AWS IAM (Least Privilege, OIDC), Secrets Manager, CloudTrail, KMS
    Observability: AWS CloudWatch (Metrics, Dashboards, SNS Alarms)
    CI/CD: GitHub Actions (Linting, Docker validation, automated Terraform apply)


Markdown

# 🏛️ Architecture Documentation

## 1. Network Topology (VPC Design)
The platform is built on a custom Virtual Private Cloud (VPC) spanning multiple Availability Zones (AZs) in `us-east-1` for high availability:
* **Public Subnets**: Route internet traffic through an Internet Gateway (IGW) to the Application Load Balancer (ALB). NAT Gateways reside here to allow private resources secure outbound internet access.
* **Private Compute Subnets**: Host the EC2 Auto Scaling instances running the containerized Node.js/Express backend. Instances have no direct public IPs.
* **Private Database Subnets**: Host the Amazon RDS PostgreSQL multi-AZ database instance, completely isolated from public access.

## 2. Compute & Elasticity Layer
* **Launch Templates**: Encapsulate a hardened Linux AMI, IAM instance profile, and bootstrap user data.
* **Auto Scaling Group (ASG)**: Automatically scales EC2 instances between a minimum of 1 and a maximum of 3 based on CPU utilization metrics and ALB health checks.

## 3. Data Flow
1. Client sends an HTTP/HTTPS request to the **ALB**.
2. The **ALB** evaluates listener rules and health checks, routing traffic to a healthy EC2 instance in the private compute tier on port `3000`.
3. The Node.js application fetches database credentials securely from **AWS Secrets Manager** at startup.
4. Application queries the **RDS PostgreSQL** database over port `5432` inside the secure private database subnet.
