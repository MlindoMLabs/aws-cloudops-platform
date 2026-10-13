# Central Log Group for Application & System Logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/cloudops/${var.environment}/app"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
  }
}

# SNS Topic for System Alerts
resource "aws_sns_topic" "alerts" {
  name = "cloudops-system-alerts-${var.environment}"
}

# Alarm: High CPU Utilization on EC2 / Auto Scaling Group
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "cloudops-high-cpu-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggered when CPU utilization exceeds 80% for 10 minutes."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

# Alarm: High Database CPU Utilization
resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name          = "cloudops-rds-high-cpu-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "Triggered when RDS CPU utilization exceeds 85%."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "cloudops-dashboard-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 ASG Average CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_id]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS CPU Utilization"
        }
      }
    ]
  })
}
