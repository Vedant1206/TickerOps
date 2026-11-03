variable "name" {
  type        = string
  description = "Name prefix for all resources, e.g. tickerops-dev"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB will be deployed"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs where the ALB will be deployed"
}