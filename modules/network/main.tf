locals {
  availability_zones = ["1a", "1c"]
  public_subnet_cidrs = [
    "${substr(var.cidr_block, 0, length(var.cidr_block) - 6)}1.0/24",
    "${substr(var.cidr_block, 0, length(var.cidr_block) - 6)}2.0/24",
  ]
  private_subnet_cidrs = [
    "${substr(var.cidr_block, 0, length(var.cidr_block) - 6)}3.0/24",
    "${substr(var.cidr_block, 0, length(var.cidr_block) - 6)}4.0/24"
  ]
}

resource "aws_vpc" "demo" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.env
  }
}

# =================================================================================
# IGW
#
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "${var.env}-igw"
  }
}

# =================================================================================
# サブネット
#
resource "aws_subnet" "public" {
  count = var.subnet_count

  vpc_id                  = aws_vpc.demo.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = "ap-northeast-${local.availability_zones[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-public-${local.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count = var.subnet_count

  vpc_id            = aws_vpc.demo.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = "ap-northeast-${local.availability_zones[count.index]}"

  tags = {
    Name = "${var.env}-private-${local.availability_zones[count.index]}"
  }
}

# =================================================================================
# NAT
#
resource "aws_eip" "ngw" {
  count = var.subnet_count

  domain = "vpc"

  tags = {
    Name = "demo-ngw"
  }

  # NATは暗黙的にIGWに依存しているため明示が必要。
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "ngw" {
  count = var.subnet_count

  allocation_id = aws_eip.ngw[count.index].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "demo-ngw${count.index}"
  }

  # NATは暗黙的にIGWに依存しているため明示が必要。
  depends_on = [aws_internet_gateway.igw]
}

# =================================================================================
# ルーティング
#
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "${var.env}-public-rtb"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  count = var.subnet_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = var.subnet_count

  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "${var.env}-private-rtb${count.index}"
  }
}

resource "aws_route" "private" {
  count = var.subnet_count

  route_table_id         = aws_route_table.private[count.index].id
  nat_gateway_id         = aws_nat_gateway.ngw[count.index].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private" {
  count = var.subnet_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
