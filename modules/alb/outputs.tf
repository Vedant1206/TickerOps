output "alb_dns_name" {
  value = aws_lb.app_load_balancer.dns_name
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.alb_target_group.arn
}

output "alb_security_group_id" {
  value = aws_security_group.security_group.id
}

output "alb_arn_suffix" {
  value = aws_lb.app_load_balancer.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.alb_target_group.arn_suffix
}