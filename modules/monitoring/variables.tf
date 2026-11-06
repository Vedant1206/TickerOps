variable "name" {
  type        = string
  description = "Name prefix for all resources, e.g. tickerops-dev"
}

variable "alert_email" {
  type        = string
  description = "Email address to send CloudWatch alerts to"
}