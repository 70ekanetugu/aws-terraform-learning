resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true # DNSサーバによる名前解決を有効化
  enable_dns_hostnames = true # VPC内リソースへのパブリックDNSホスト名割り当てを有効化

  tags = {
    Name = "example"
  }
}

module "public_subnets" {
  source = "./modules/subnet"

  vpc_id             = aws_vpc.default.id
  is_public          = true
  availability_zones = local.availability_zones
  tag_name           = "example-subnet-public"
}

module "private_subnets" {
  source = "./modules/subnet"

  vpc_id             = aws_vpc.default.id
  is_public          = false
  availability_zones = local.availability_zones
  tag_name           = "example-subnet-private"
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "example-igw"
  }
}
