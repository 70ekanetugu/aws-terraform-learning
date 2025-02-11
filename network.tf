# =====================================================================================================
# VPC
# =====================================================================================================
resource "aws_vpc" "this" {
  cidr_block = "${var.cidr_block_prefix}.0.0/16"

  tags = {
    Name = "${local.sys_name}-${var.env}"
  }
}

# =====================================================================================================
# ゲートウェイ
# =====================================================================================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.sys_name}-${var.env}"
  }
}

# =====================================================================================================
# サブネット(AZの数だけ用意する)
# =====================================================================================================
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  availability_zone       = var.availability_zones[count.index]
  cidr_block              = "${var.cidr_block_prefix}.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = "${local.sys_name}-${var.env}-public-${count.index}"
  }
}
resource "aws_subnet" "private_ap" {
  count = length(var.availability_zones)

  availability_zone       = var.availability_zones[count.index]
  cidr_block              = "${var.cidr_block_prefix}.1${count.index + 1}.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = "${local.sys_name}-${var.env}-private-ap-${count.index}"
  }
}
resource "aws_subnet" "private_db" {
  count = length(var.availability_zones)

  availability_zone       = var.availability_zones[count.index]
  cidr_block              = "${var.cidr_block_prefix}.2${count.index + 1}.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = "${local.sys_name}-${var.env}-private-db-${count.index}"
  }
}
resource "aws_subnet" "private_ep" {
  count = length(var.availability_zones)

  availability_zone       = var.availability_zones[count.index]
  cidr_block              = "${var.cidr_block_prefix}.4${count.index + 1}.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = "${local.sys_name}-${var.env}-private-ep-${count.index}"
  }
}

# =====================================================================================================
# ルートテーブル
# =====================================================================================================
# publicサブネット用
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.sys_name}-${var.env}-public-rtb"
  }
}
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# 全privateサブネットで共用するルートテーブル
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.sys_name}-${var.env}-private-rtb"
  }
}

# =====================================================================================================
# サブネット - ルートテーブル紐付け
# =====================================================================================================
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}
# privateサブネットはすべて同じルートテーブルを紐づける
resource "aws_route_table_association" "private_ap" {
  count = length(aws_subnet.private_ap)

  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_ap[count.index].id
}
resource "aws_route_table_association" "private_db" {
  count = length(aws_subnet.private_db)

  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_db[count.index].id
}
resource "aws_route_table_association" "private_ep" {
  count = length(aws_subnet.private_ep)

  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_ep[count.index].id
}
