variable "alert_email" {
  type        = string
  description = "Email address to send CloudWatch alerts to"
}

variable "image_tag" {
  type        = string
  description = "Git SHA tag of the app image in ECR"
}