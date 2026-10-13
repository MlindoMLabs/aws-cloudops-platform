# 1. Fetch Latest Canonical Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. IAM Role for Systems Manager (SSM)
resource "aws_iam_role" "ec2_ssm_role" {
  name = "cloudops-${var.environment}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "cloudops-${var.environment}-ec2-ssm-role"
  }
}

# Attach AWS Managed SSM Core Policy
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile to attach Role to EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "cloudops-${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# 3. Security Group (Outbound Internet only, No open inbound SSH needed)
resource "aws_security_group" "ec2_sg" {
  name        = "cloudops-${var.environment}-ec2-sg"
  description = "Security group for application compute host"
  vpc_id      = var.vpc_id

  # Allow full outbound access (for downloading packages & communicating with AWS SSM)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloudops-${var.environment}-ec2-sg"
  }
}

# 4. User Data Script: Auto Install Docker & Tools on Startup
locals {
  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # System Updates
              apt-get update -y
              apt-get install -y ca-certificates curl gnupg lsb-release unzip
              
              # Install Docker GPG key & repo
              install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              chmod a+r /etc/apt/keyrings/docker.asc
              
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                tee /etc/apt/sources.list.d/docker.list > /dev/null
              
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
              
              # Enable and start Docker
              systemctl enable docker
              systemctl start docker
              
              # Add default ubuntu user to docker group
              usermod -aG docker ubuntu
              
              # Install AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install
              rm -rf awscliv2.zip aws
              EOF
}

# 5. Launch EC2 Instance in Public Subnet
resource "aws_instance" "app_node" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = local.user_data

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "cloudops-${var.environment}-app-host"
  }
}

# Fix Security Group Rule (use local resource and variable)
resource "aws_security_group_rule" "allow_alb_to_ec2" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = var.alb_security_group_id
}

resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = var.secrets_policy_arn
}

# In terraform/modules/ec2/main.tf
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_policy" "ec2_least_privilege" {
  name        = "${var.environment}-ec2-least-privilege-policy"
  description = "Least privilege access policy for EC2 runtime"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReadingDatabaseSecret"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secrets_policy_arn
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
