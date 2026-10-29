variable "name" {
  type        = string
  description = "Name prefix for all resources, e.g. tickerops-dev"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID which will be used by SG for ECS service"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID for the ECS service to allow traffic from the ALB"
}