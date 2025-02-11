# ===========================================================================
# ALB
# ===========================================================================
resource "aws_lb" "front" {
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false
  security_groups            = [module.public_alb_sg.security_group_id]
  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  tags = {
    Name = "demo-front-alb"
  }
}
resource "aws_lb_listener" "front" {
  load_balancer_arn = aws_lb.front.arn
  port              = 80
  protocol          = "HTTP"

  # 後述リスナールールのいずれも一致しない場合の動作設定
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = <<JSON
      {
        "err_msg": "No setting"
      }
      JSON
      status_code  = 404
    }
  }
}
resource "aws_lb_target_group" "front" {
  name                 = "demo-front-alb-tg"
  target_type          = "ip" # Fargateでは"ip"固定
  vpc_id               = aws_vpc.demo.id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 300 # ターゲットの登録解除前にALBが待機する時間(s)。デフォルトは300

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.front]
}
resource "aws_lb_listener_rule" "front" {
  listener_arn = aws_lb_listener.front.arn
  priority     = 100

  # 本リスナールールに合致するものは、ターゲットグループへフォワードする
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }

  condition {
    # すべてのパスをフォーワード
    path_pattern {
      values = ["/*"]
    }
  }
}

# ===========================================================================
# Nginx用のクラスタ
# ===========================================================================
resource "aws_ecs_cluster" "front" {
  name = "demo-front"

  tags = {
    Name = "demo-front"
  }
}
resource "aws_ecs_task_definition" "front" {
  family                   = "demo-front"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = <<JSON
  [
    {
      "name": "demo-front",
      "image": "nginx:latest",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "nginx",
          "awslogs-group": "/demo/front"
        }
      },
      "portMappings": [
        {
          "protocol": "tcp",
          "containerPort": 80
        }
      ]
    }
  ]
  JSON
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}
resource "aws_ecs_service" "front" {
  name                              = "demo-front-service"
  cluster                           = aws_ecs_cluster.front.arn
  task_definition                   = aws_ecs_task_definition.front.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups  = [module.private_front_ap.security_group_id]

    subnets = [
      aws_subnet.private_ap_1a.id,
      aws_subnet.private_ap_1c.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.front.arn
    container_name   = "demo-front"
    container_port   = 80
  }

  lifecycle {
    # ignore_changes = [task_definition]
  }
}

#
# CloudWatch Logs
#
resource "aws_cloudwatch_log_group" "front" {
  name              = "/demo/front"
  retention_in_days = 180
}

data "aws_iam_policy" "front" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "front" {
  source_policy_documents = [data.aws_iam_policy.front.policy]

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

module "ecs_task_execution_role" {
  source     = "./modules/iam_role"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.front.json
}
