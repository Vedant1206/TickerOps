variable "name" {
  type        = string
  description = "Name prefix for all resources, e.g. tickerops-dev"
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR range for the VPC"
}