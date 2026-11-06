resource "aws_sns_topic" "email_alerts" {
  name = "${var.name}-alerts"
  tags = {
    Name = "${var.name}-alerts"
  }
}

resource "aws_sns_topic_subscription" "email_alerts_subscription" {
  topic_arn = aws_sns_topic.email_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
