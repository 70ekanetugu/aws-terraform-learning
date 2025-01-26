module "public_alb" {
  source = "./modules/alb"

  vpc_id             = aws_vpc.default.id
  name               = "example-public-alb"
  subnet_ids         = [for id in module.public_subnets.ids : id]
  security_group_ids = [module.http_sg.id]
  target_group_name  = "example-public-tg"
  target_type        = "ip"
  protocol           = "HTTP"
  listen_port        = 80
  target_port        = 80
  is_internal        = false
}
