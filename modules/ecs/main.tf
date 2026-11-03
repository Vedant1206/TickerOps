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

# ECS has to do two jobs for you:
# 1. pull the image (nginx now, your app from ECR later)
# 2. send the logs to CloudWatch (step 7)


resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecs-execution-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.name}-ecs-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/${var.name}"

  retention_in_days = 7

  tags = {
    Name = "/ecs/${var.name}"
  }
}

# Recipe for one container
resource "aws_ecs_task_definition" "container_task_definition" {
  family                   = "${var.name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name,
          "awslogs-region"        = "ca-central-1",
          "awslogs-stream-prefix" = "nginx"
        }
      }
    }
  ])
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  tags = {
    Name = "${var.name}-task"
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.name}-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.container_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }

}
