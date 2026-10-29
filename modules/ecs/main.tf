resource "aws_security_group" "ecs_security_group" {
  name        = "${var.name}-ecs-sg"
  description = "Security group for the ECS service"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-ecs-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_http_in" {
  security_group_id            = aws_security_group.ecs_security_group.id
  referenced_security_group_id = var.alb_security_group_id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "ecs_all_out" {
  security_group_id = aws_security_group.ecs_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}-ecs-cluster"

  tags = {
    Name = "${var.name}-ecs-cluster"
  }
}
