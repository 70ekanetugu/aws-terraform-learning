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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = var.env
  }
}

resource "aws_subnet" "public" {
  count = var.subnet_count

  vpc_id                  = aws_vpc.demo.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = "ap-northeast-${local.availability_zones[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-${local.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count = var.subnet_count

  vpc_id            = aws_vpc.demo.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = "ap-northeast-${local.availability_zones[count.index]}"

  tags = {
    Name = "${var.env}-${local.availability_zones[count.index]}"
  }
}
