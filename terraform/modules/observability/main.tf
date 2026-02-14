# SNS Topic for Alarms

resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-cloudwatch-alarms"
}

# AWS Chatbot Slack Config

resource "aws_chatbot_slack_channel_configuration" "slack" {
  name               = "${var.environment}-slack-alerts"
  slack_workspace_id = var.slack_workspace_id
  slack_channel_id   = var.slack_channel_id

  sns_topic_arns = [aws_sns_topic.alerts.arn]

  logging_level = "ERROR"
}

# RDS CPU Alarm

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.environment}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU usage is above 80%"
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# RDS Free Storage Alarm

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${var.environment}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5000000000 # 5GB
  alarm_description   = "RDS free storage below 5GB"
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ALB 5XX Alarm

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.environment}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB returning high 5XX errors"
  dimensions = {
    LoadBalancer = var.alb_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
