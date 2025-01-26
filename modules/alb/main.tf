resource "aws_lb" "default" {
  load_balancer_type         = "application"
  name                       = var.name
  idle_timeout               = 60
  internal                   = var.is_internal
  security_groups            = var.security_group_ids
  subnets                    = var.subnet_ids
  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = var.log_bucket_id
    enabled = var.log_bucket_id != ""
  }
}

resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.default.arn
  port              = var.listen_port
  protocol          = var.protocol

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "これは「HTTP」です"
      status_code  = "200"
    }
  }
}

resource "aws_lb_target_group" "default" {
  name                 = var.target_group_name
  target_type          = var.target_type
  vpc_id               = var.vpc_id
  port                 = var.target_port
  protocol             = var.protocol
  deregistration_delay = 300

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = var.protocol
  }

  depends_on = [aws_lb.default]
}

resource "aws_lb_listener_rule" "default" {
  listener_arn = aws_lb_listener.default.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
