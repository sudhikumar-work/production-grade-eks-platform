variable "environment" {
  description = "Environment name"
  type        = string
}

variable "rds_instance_id" {
  description = "RDS instance identifier"
  type        = string
}

variable "alb_name" {
  description = "ALB name"
  type        = string
}

variable "slack_workspace_id" {
  description = "Slack Workspace ID for AWS Chatbot"
  type        = string
}

variable "slack_channel_id" {
  description = "Slack Channel ID for aws-alarms"
  type        = string
}
