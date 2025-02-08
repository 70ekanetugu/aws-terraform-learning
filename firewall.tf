# ===================================================================================
# セキュリティグループ
# ===================================================================================
# ALB(public)用
module "public_alb_sg" {
  source = "./modules/security_group"
  name   = "demo-public-alb"
  vpc_id = aws_vpc.demo.id

  ingress_port_and_protocol = [
    {
      port     = "80"
      protocol = "tcp"
    },
    {
      port     = "443"
      protocol = "tcp"
    },
  ]
  ingress_source = {
    cidr_ipv4 = "0.0.0.0/0"
  }
}

# ALB(private)用
module "private_alb_sg" {
  source = "./modules/security_group"
  name   = "demo-private-alb"
  vpc_id = aws_vpc.demo.id

  ingress_port_and_protocol = [
    {
      port     = "80"
      protocol = "tcp"
    },
    {
      port     = "8080"
      protocol = "tcp"
    }
  ]
  ingress_source = {
    cidr_ipv4 = "0.0.0.0/0"
  }
}

# アプリケーション(private)用。 ALB(private)からのみ許可する。
module "private_ap" {
  source = "./modules/security_group"
  name   = "demo-private-ap"
  vpc_id = aws_vpc.demo.id
  ingress_port_and_protocol = [
    {
      port     = "80"
      protocol = "tcp"
    },
    {
      port     = "8080"
      protocol = "tcp"
    }
  ]
  ingress_source = {
    referenced_sg_id = module.private_alb_sg.security_group_id
  }
}

# DB(MySQL)用
module "mysql_sg" {
  source = "./modules/security_group"
  name   = "demo-mysql-sg"
  vpc_id = aws_vpc.demo.id

  ingress_port_and_protocol = [
    {
      port     = "3306"
      protocol = "tcp"
    }
  ]
  ingress_source = {
    cidr_ipv4 = aws_vpc.demo.cidr_block
  }
}

# VPCエンドポイント用
module "endpoint_sg" {
  source = "./modules/security_group"
  name   = "demo-endpoint-sg"
  vpc_id = aws_vpc.demo.id

  ingress_port_and_protocol = [{
    port     = "-1"
    protocol = "-1"
  }]
  ingress_source = {
    cidr_ipv4 = aws_vpc.demo.cidr_block
  }
}
