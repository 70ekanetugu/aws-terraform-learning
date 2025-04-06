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
  count = length(var.ingress_rule_by_cidr_block)

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = var.ingress_rule_by_cidr_block[count.index]["cidr_ipv4"]
  from_port         = var.ingress_rule_by_cidr_block[count.index]["port"]
  to_port           = var.ingress_rule_by_cidr_block[count.index]["port"]
  ip_protocol       = var.ingress_rule_by_cidr_block[count.index]["protocol"]
}

# アクセス元を他のセキュリティグループで指定する場合に設定するルール。
resource "aws_vpc_security_group_ingress_rule" "referenced_security_group" {
  count = length(var.ingress_rule_by_referenced_sg)

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.ingress_rule_by_referenced_sg[count.index]["referenced_sg_id"]
  from_port                    = var.ingress_rule_by_referenced_sg[count.index]["port"]
  ip_protocol                  = var.ingress_rule_by_referenced_sg[count.index]["protocol"]
  to_port                      = var.ingress_rule_by_referenced_sg[count.index]["port"]
}
