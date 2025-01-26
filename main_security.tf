module "http_sg" {
  source = "./modules/security_group"

  name        = "example-http-sg"
  vpc_id      = aws_vpc.default.id
  from_port   = 0
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

module "ssh_sg" {
  source = "./modules/security_group"

  name        = "example-ssh-sg"
  vpc_id      = aws_vpc.default.id
  from_port   = 0
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
