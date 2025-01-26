resource "aws_security_group" "default" {
  vpc_id = var.vpc_id
  name   = var.name
}

resource "aws_security_group_rule" "ingress" {
  security_group_id = aws_security_group.default.id
  type              = "ingress"
  from_port         = var.from_port
  to_port           = var.to_port
  protocol          = var.protocol
  cidr_blocks       = var.cidr_blocks
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.default.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
