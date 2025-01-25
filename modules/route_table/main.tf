resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = {
    Name = "example-public-rtb"
  }
}
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = {
    Name = "example-private-rtb"
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}
