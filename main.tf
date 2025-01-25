terraform {
  # terraformバージョン違いによるトラブル防止のため設定。
  # チーム開発の場合は特に設定することを推奨。
  required_version = "~>1.10"
  # プロバイダ(aws)の進化が早く環境差異が出やすいため、同じくバージョン指定を推奨。
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

#
# vpc ======================================================================
#
module "vpc" {
  source = "./modules/vpc"

  tag_name = "example"
}

#
# subnet ======================================================================
#
module "subnet_public" {
  source = "./modules/subnet"

  vpc_id             = module.vpc.vpc_id
  is_public          = true
  availability_zones = local.availability_zones
  tag_name           = "example-subnet-public"
}
module "subnet_private" {
  source = "./modules/subnet"

  vpc_id             = module.vpc.vpc_id
  is_public          = false
  availability_zones = local.availability_zones
  tag_name           = "example-subnet-private"
}

#
# route_table ======================================================================
#
module "route_table" {
  source = "./modules/route_table"

  vpc_id = module.vpc.vpc_id
  igw_id = module.vpc.igw_id
}

resource "aws_route_table_association" "public" {
  for_each = module.subnet_public.ids

  subnet_id      = each.value
  route_table_id = module.route_table.public_id
}
resource "aws_route_table_association" "private" {
  for_each = module.subnet_private.ids

  subnet_id      = each.value
  route_table_id = module.route_table.private_id
}
