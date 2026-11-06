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

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.name}-unhealthy-hosts"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  statistic           = "Maximum"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60
  threshold           = 0
  alarm_actions       = [aws_sns_topic.email_alerts.arn]
  ok_actions          = [aws_sns_topic.email_alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  tags = {
    Name = "${var.name}-unhealthy-hosts"
  }

}
