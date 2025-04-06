#
# S3
#
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.demo.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
}
resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.private_ep.id
}

#
# CloudWatch
#
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_ep_1a.id, aws_subnet.private_ep_1c.id]
  security_group_ids  = [module.endpoint_sg.security_group_id]
  private_dns_enabled = true
}

#
# SSM
#
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_ep_1a.id, aws_subnet.private_ep_1c.id]
  security_group_ids  = [module.endpoint_sg.security_group_id]
  private_dns_enabled = true
}

#
# ECR
#
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_ep_1a.id, aws_subnet.private_ep_1c.id]
  security_group_ids  = [module.endpoint_sg.security_group_id]
  private_dns_enabled = true
}
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private_ep_1a.id, aws_subnet.private_ep_1c.id]
  security_group_ids  = [module.endpoint_sg.security_group_id]
  private_dns_enabled = true
}
