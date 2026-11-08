variable "name" {
  type        = string
  description = "Name prefix for all resources, e.g. tickerops-dev"
}

variable "alert_email" {
  type        = string
  description = "Email address to send CloudWatch alerts to"
}

variable "alb_arn_suffix" {
  type        = string
  description = "ARN suffix of the ALB to monitor for unhealthy hosts"
}

variable "target_group_arn_suffix" {
  type        = string
  description = "ARN suffix of the target group to monitor for unhealthy hosts"
}

variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster to monitor for higher CPU utilization"
}

variable "service_name" {
  type        = string
  description = "Name of the ECS service to monitor for higher CPU utilization"
}