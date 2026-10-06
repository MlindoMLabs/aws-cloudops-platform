# 1. Security Group for Public Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "cloudops-${var.environment}-alb-sg"
  description = "Allow inbound HTTP traffic from internet to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow inbound HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic to EC2 target group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloudops-${var.environment}-alb-sg"
  }
}

# 2. Application Load Balancer
resource "aws_lb" "main" {
  name               = "cloudops-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "cloudops-${var.environment}-alb"
  }
}

# 3. Target Group for Node.js App
resource "aws_lb_target_group" "app" {
  name        = "cloudops-${var.environment}-app-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "cloudops-${var.environment}-app-tg"
  }
}

# 4. Listener (Port 80 HTTP Forwarding to Target Group)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
