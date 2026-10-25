variable "name" {
  type        = string
  description = "Name prefix for all resources, e.g. tickerops-dev"
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR range for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones to use for subnets"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
}