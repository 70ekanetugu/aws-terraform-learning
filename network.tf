locals {
  cidr_blocks = {
    vpc           = "10.0.0.0/16"
    public_1a     = "10.0.1.0/24"
    public_1c     = "10.0.2.0/24"
    private_ap_1a = "10.0.3.0/24"
    private_ap_1c = "10.0.4.0/24"
    private_db_1a = "10.0.5.0/24"
    private_db_1c = "10.0.6.0/24"
    private_ep_1a = "10.0.7.0/24"
    private_ep_1c = "10.0.8.0/24"
  }
}
# ===================================================================================
# VPC
# ===================================================================================
resource "aws_vpc" "demo" {
  cidr_block           = local.cidr_blocks["vpc"]
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "demo"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "demo-igw"
  }
}

# ===================================================================================
# Subnets
# ===================================================================================
# publicサブネット
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = local.cidr_blocks["public_1a"]
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "demo-public-subnet-1a"
  }
}
resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = local.cidr_blocks["public_1c"]
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "demo-public-subnet-1c"
  }
}
# private(AP)サブネット
resource "aws_subnet" "private_ap_1a" {
  vpc_id            = aws_vpc.demo.id
  cidr_block        = local.cidr_blocks["private_ap_1a"]
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "demo-private-ap-subnet-1a"
  }
}
resource "aws_subnet" "private_ap_1c" {
  vpc_id            = aws_vpc.demo.id
  cidr_block        = local.cidr_blocks["private_ap_1c"]
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "demo-private-ap-subnet-1c"
  }
}

# private(DB)サブネット
resource "aws_subnet" "private_db_1a" {
  vpc_id            = aws_vpc.demo.id
  cidr_block        = local.cidr_blocks["private_db_1a"]
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "demo-private-db-subnet-1a"
  }
}
resource "aws_subnet" "private_db_1c" {
  vpc_id            = aws_vpc.demo.id
  cidr_block        = local.cidr_blocks["private_db_1c"]
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "demo-private-db-subnet-1c"
  }
}

# VPCエンドポイント用
resource "aws_subnet" "private_ep_1a" {
  vpc_id            = aws_vpc.demo.id
  cidr_block        = local.cidr_blocks["private_ep_1a"]
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "demo-private-ep-subnet-1a"
  }
}
resource "aws_subnet" "private_ep_1c" {
  vpc_id            = aws_vpc.demo.id
  cidr_block        = local.cidr_blocks["private_ep_1c"]
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "demo-private-ep-subnet-1c"
  }
}

# ===================================================================================
# ルートテーブル 
# ===================================================================================
# publicサブネット用のルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo.id
}
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "public_1a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1a.id
}
resource "aws_route_table_association" "public_1c" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_1c.id
}
# private(AP)用のルートテーブル (※ローカルルートはデフォルトで作られるのでprivateサブネットについてaws_routeの設定は不要))
# resource "aws_route_table" "private_ap" {
#   vpc_id = aws_vpc.demo.id
# }
# resource "aws_route_table_association" "private_ap_1a" {
#   route_table_id = aws_route_table.private_ap.id
#   subnet_id      = aws_subnet.private_ap_1a.id
# }
# resource "aws_route_table_association" "private_ap_1c" {
#   route_table_id = aws_route_table.private_ap.id
#   subnet_id      = aws_subnet.private_ap_1c.id
# }
# private(ep)用のルートテーブル。
resource "aws_route_table" "private_ep" {
  vpc_id = aws_vpc.demo.id
}
resource "aws_route_table_association" "private_ep_1a" {
  route_table_id = aws_route_table.private_ep.id
  subnet_id      = aws_subnet.private_ep_1a.id
}
resource "aws_route_table_association" "private_ep_1c" {
  route_table_id = aws_route_table.private_ep.id
  subnet_id      = aws_subnet.private_ep_1c.id
}

# ===================================================================================
# NAT ：
# ===================================================================================
# NATを使う場合EIPを別で用意する必要がある。
resource "aws_eip" "ngw_1a" {
  domain = "vpc"

  tags = {
    Name = "demo-eip-ngw-1a"
  }

  depends_on = [aws_internet_gateway.igw]
}
resource "aws_eip" "ngw_1c" {
  domain = "vpc"

  tags = {
    Name = "demo-eip-ngw-1c"
  }

  depends_on = [aws_internet_gateway.igw]
}
# NATはAZごとに置くのが普通。
resource "aws_nat_gateway" "ngw_1a" {
  allocation_id = aws_eip.ngw_1a.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name = "demo-ngw-1a"
  }

  depends_on = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "ngw_1c" {
  allocation_id = aws_eip.ngw_1c.id
  subnet_id     = aws_subnet.public_1c.id

  tags = {
    Name = "demo-ngw-1c"
  }

  depends_on = [aws_internet_gateway.igw]
}
# デフォルトルートはルートテーブル1つにつき1つまでしか定義できないため、NATを使う場合はAZごとに作る必要がある。
resource "aws_route_table" "private_ap_1a" {
  vpc_id = aws_vpc.demo.id
}
resource "aws_route_table" "private_ap_1c" {
  vpc_id = aws_vpc.demo.id
}
resource "aws_route" "private_1a" {
  route_table_id         = aws_route_table.private_ap_1a.id
  nat_gateway_id         = aws_nat_gateway.ngw_1a.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route" "private_1c" {
  route_table_id         = aws_route_table.private_ap_1c.id
  nat_gateway_id         = aws_nat_gateway.ngw_1c.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "private_ap_1a" {
  subnet_id      = aws_subnet.private_ap_1a.id
  route_table_id = aws_route_table.private_ap_1a.id
}
resource "aws_route_table_association" "private_ap_1c" {
  subnet_id      = aws_subnet.private_ap_1c.id
  route_table_id = aws_route_table.private_ap_1c.id
}
