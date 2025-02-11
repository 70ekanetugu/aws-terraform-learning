# =====================================================================================================
# セキュリティグループ 
# =====================================================================================================
# publicサブネットのALB用。
module "public-alb_sg" {
  source = "./modules/security_group"

  name   = "${local.sys_name}-${var.env}-public-alb-sg"
  vpc_id = aws_vpc.this.id

  ingress_port_and_protocol = [
    { port = "80", protocol = "tcp" },
    { port = "443", protocol = "tcp" }
  ]
  ingress_source = { cidr_ipv4 = "0.0.0.0/0" }
}

# publicサブネットに配置するAP用。外部からのアクセスは受け付けず、外向きの通信のみ許可する。
module "public_ap_sg" {
  source = "./modules/security_group"

  name   = "${local.sys_name}-${var.env}-public-ap-sg"
  vpc_id = aws_vpc.this.id

  ingress_port_and_protocol = [
    { port = "0", protocol = "tcp" }
  ]
  ingress_source = { cidr_ipv4 = aws_vpc.this.cidr_block }
}

# private_apサブネット用。web, ap, internal-alb用に使用する。
module "private_ap_sg" {
  source = "./modules/security_group"

  name   = "${local.sys_name}-${var.env}-private-ap-sg"
  vpc_id = aws_vpc.this.id

  ingress_port_and_protocol = [
    { port = "80", protocol = "tcp" },
    { port = "8080", protocol = "tcp" }
  ]
  ingress_source = {
    cidr_ipv4 = aws_vpc.this.cidr_block
  }
}

module "mysql_sg" {
  source = "./modules/security_group"

  name   = "${local.sys_name}-${var.env}-mysql-sg"
  vpc_id = aws_vpc.this.id

  ingress_port_and_protocol = [
    { port = "3306", protocol = "tcp" }
  ]
  ingress_source = {
    referenced_sg_id = module.private_ap_sg.security_group_id
  }
}

# VPCエンドポイント用のセキュリティグループ
module "endpoint_sg" {
  source = "./modules/security_group"

  name   = "${local.sys_name}-${var.env}-ep-sg"
  vpc_id = aws_vpc.this.id

  ingress_port_and_protocol = [
    { port = "443", protocol = "tcp" }
  ]
  ingress_source = {
    cidr_ipv4 = aws_vpc.this.cidr_block
  }
}
