resource "aws_vpc" "default" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true # DNSサーバによる名前解決を有効化
  enable_dns_hostnames = true # VPC内リソースへのパブリックDNSホスト名割り当てを有効化

  tags = {
    Name = "example"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "example-igw"
  }
}
