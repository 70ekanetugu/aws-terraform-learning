# =============================================================================
# Public ALB for web
#
module "public_http_sg" {
  source                    = "./modules/security_group"
  vpc_id                    = module.network.vpc_id
  sg_name                   = "demo-public-http-sg"
  env                       = "demo"
  ingress_allow_cidr_blocks = ["0.0.0.0/0"]
  ingress_from_port         = 80
  ingress_to_port           = 80
}
resource "aws_lb" "web" {
  name                       = "demo-web"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    module.network.subnet_public[0].id,
    module.network.subnet_public[1].id
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.public_http_sg.security_group_id
  ]
}
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}
resource "aws_lb_target_group" "web" {
  name                 = "demo-web"
  target_type          = "ip"
  vpc_id               = module.network.vpc_id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 300

  health_check {
    path                = "/hello"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.web]
}
resource "aws_lb_listener_rule" "web" {
  listener_arn = aws_lb_listener.web.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# =============================================================================
# Private(Internal) ALB for ap
# 
module "private_http_sg" {
  source                    = "./modules/security_group"
  vpc_id                    = module.network.vpc_id
  sg_name                   = "demo-private-http-sg"
  env                       = "demo"
  ingress_allow_cidr_blocks = [module.network.vpc_cidr_block]
  ingress_from_port         = 80
  ingress_to_port           = 80
}
resource "aws_lb" "ap" {
  name                       = "demo-ap"
  load_balancer_type         = "application"
  internal                   = true
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    module.network.subnet_private[0].id,
    module.network.subnet_private[1].id
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.private_http_sg.security_group_id
  ]
}
resource "aws_lb_listener" "ap" {
  load_balancer_arn = aws_lb.ap.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}
resource "aws_lb_target_group" "ap" {
  name                 = "demo-ap"
  target_type          = "ip"
  vpc_id               = module.network.vpc_id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 300

  health_check {
    path                = "/hello"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.ap]
}
resource "aws_lb_listener_rule" "ap" {
  listener_arn = aws_lb_listener.ap.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ap.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
