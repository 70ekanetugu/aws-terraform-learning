# ===========================================================================
# Nginx用のクラスタ
# ===========================================================================
# resource "aws_ecs_cluster" "front" {
#   name = "demo-front"

#   tags = {
#     Name = "demo-front"
#   }
# }

# resource "aws_ecs_task_definition" "front" {
#   cpu = 256
#   family = ""
#   container_definitions = <<JSON
#   [
#     {
#       "": ""
#     }
#   ]
#   JSON
# }
# resource "aws_ecs_service" "front" {
#   name = "demo-front-service"
# }
# resource "aws_ecs" "name" {

# }

# ===========================================================================
# ALB
# ===========================================================================
resource "aws_lb" "front" {
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.public_alb_sg.security_group_id
  ]
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
  deregistration_delay = 15 # ターゲットの登録解除前にALBが待機する時間(s)。デフォルトは300

  health_check {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
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
