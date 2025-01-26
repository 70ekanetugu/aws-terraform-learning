module "http_sg" {
  source = "./modules/security_group"

  name        = "example-http-sg"
  vpc_id      = aws_vpc.default.id
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
