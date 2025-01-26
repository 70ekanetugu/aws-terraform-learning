data "aws_ami" "amzn_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_key_pair" "ssh" {
  key_name = "ec2-pub-key"
  public_key = var.ssh_pub_key
}

resource "aws_instance" "httpd" {
  ami                    = data.aws_ami.amzn_linux_2023.id
  instance_type          = "t2.nano"
  subnet_id              = module.private_subnets.ids[0]
  vpc_security_group_ids = [module.http_sg.id]
  key_name = aws_key_pair.ssh.key_name

  user_data = file("init.sh")

  tags = {
    Name = "example-httpd-1a"
  }
}


module "public_alb" {
  source = "./modules/alb"

  vpc_id             = aws_vpc.default.id
  name               = "example-public-alb"
  subnet_ids         = [for id in module.public_subnets.ids : id]
  security_group_ids = [module.http_sg.id]
  target_group_name  = "example-public-tg"
  protocol           = "HTTP"
  listen_port        = 80
  target_port        = 80
  is_internal        = false
}

resource "aws_lb_target_group_attachment" "httpd" {
  target_group_arn = module.public_alb.target_group_arn
  target_id        = aws_instance.httpd.id
  port             = 80
}
