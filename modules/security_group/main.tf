# ===================================================================================
# セキュリティグループ
# ===================================================================================
# public ALB用
resource "aws_security_group" "this" {
  name   = var.name
  vpc_id = var.vpc_id

  tags = {
    Name = var.name
  }
}
resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "-1"
  to_port           = -1
}

# アクセス元をcidr_ipv4で指定する場合に設定するingressルール。
resource "aws_vpc_security_group_ingress_rule" "cidr_ipv4" {
  count = contains(keys(var.ingress_source), "referenced_sg_id") ? 0 : length(var.ingress_port_and_protocol)

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = var.ingress_source["cidr_ipv4"]
  from_port         = var.ingress_port_and_protocol[count.index]["port"]
  ip_protocol       = var.ingress_port_and_protocol[count.index]["protocol"]
  to_port           = var.ingress_port_and_protocol[count.index]["port"]
}

# アクセス元を他のセキュリティグループで指定する場合に設定するルール。
resource "aws_vpc_security_group_ingress_rule" "referenced_security_group" {
  count = contains(keys(var.ingress_source), "referenced_sg_id") ? length(var.ingress_port_and_protocol) : 0

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.ingress_source["referenced_sg_id"]
  from_port                    = var.ingress_port_and_protocol[count.index]["port"]
  ip_protocol                  = var.ingress_port_and_protocol[count.index]["protocol"]
  to_port                      = var.ingress_port_and_protocol[count.index]["port"]
}
