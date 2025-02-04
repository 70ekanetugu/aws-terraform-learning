#
# インバウンドに関する設定を入力で指定すること。
# アウトバウンドはすべて許可される。
#
resource "aws_security_group" "default" {
  vpc_id = var.vpc_id
  name   = var.sg_name

  tags = {
    Name = var.env
  }
}

resource "aws_security_group_rule" "ingress" {
  security_group_id = aws_security_group.default.id
  type              = "ingress"
  cidr_blocks       = var.ingress_allow_cidr_blocks
  from_port         = var.ingress_from_port
  to_port           = var.ingress_to_port
  protocol          = var.ingress_protocol
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.default.id
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
