module "route_tables" {
  source = "./modules/route_table"

  vpc_id = aws_vpc.default.id
  igw_id = aws_internet_gateway.default.id
}

resource "aws_route_table_association" "public" {
  for_each = module.public_subnets.ids

  route_table_id = module.route_tables.public_id
  subnet_id      = each.value
}

resource "aws_route_table_association" "private" {
  for_each = module.private_subnets.ids

  route_table_id = module.route_tables.private_id
  subnet_id      = each.value
}
