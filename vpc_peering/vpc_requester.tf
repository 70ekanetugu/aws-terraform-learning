locals {
  requester_name = "kanetugu-requester"
}

# =================================================================================
# ネットワーク
# =================================================================================
#
# SessionManagerでアクセスする用のVPC
#
resource "aws_vpc" "requester" {
  cidr_block           = "${var.requester_cidr_block_prefix}.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.requester_name}-vpc"
  }
}
#
# NAT設置用のpublicサブネット(踏み台->ネットワークアクセスのために用意。逆方向は許可しない)
#
resource "aws_subnet" "public" {
  availability_zone = "${var.region}a"
  cidr_block        = "${var.requester_cidr_block_prefix}.100.0/24"
  vpc_id            = aws_vpc.requester.id

  tags = {
    Name = "${local.requester_name}-public"
  }
}
#
# 踏み台サーバ用のprivateサブネット
#
resource "aws_subnet" "requester" {
  availability_zone = "ap-northeast-1a"
  cidr_block        = "${var.requester_cidr_block_prefix}.0.0/24"
  vpc_id            = aws_vpc.requester.id

  tags = {
    Name = "${local.requester_name}-private"
  }
}

# =================================================================================
# ゲートウェイ(IGW, NAT-GW)
# ================================================================================
#
# IGW
#
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.requester.id

  tags = {
    Name = "${local.requester_name}-igw"
  }
}
#
# NAT gateway
#
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${local.requester_name}-nat"
  }

  depends_on = [aws_eip.nat]
}
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${local.requester_name}-nat-eip"
  }
}

# ==================================================================================
# ルートテーブル
# =================================================================================
#
# publicサブネット用のルートテーブル
#
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.requester.id

  tags = {
    Name = "${local.requester_name}-public-rtb"
  }
}
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

#
# privateサブネット用のルートテーブル
#
resource "aws_route_table" "requester" {
  vpc_id = aws_vpc.requester.id

  tags = {
    Name = "${local.requester_name}-private-rtb"
  }
}
resource "aws_route" "private" {
  route_table_id         = aws_route_table.requester.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
resource "aws_route_table_association" "requester" {
  subnet_id      = aws_subnet.requester.id
  route_table_id = aws_route_table.requester.id

  depends_on = [aws_vpc_peering_connection.peering]
}

# =================================================================================
# セキュリティグループ 
# =================================================================================
# 
# VPCエンドポイント用
#
module "sg_vpc_endpoint" {
  source = "../modules/security_group"
  vpc_id = aws_vpc.requester.id
  name   = "${local.requester_name}-sg"
  ingress_rule_by_cidr_block = [
    {
      cidr_ipv4 = aws_vpc.requester.cidr_block
      port      = "443"
      protocol  = "tcp"
    }
  ]
}
#
# EC2, ECS用
#
module "sg_compute" {
  source = "../modules/security_group"
  vpc_id = aws_vpc.requester.id
  name   = "${local.requester_name}-ec2-sg"
  ingress_rule_by_cidr_block = [
    {
      cidr_ipv4 = aws_vpc.requester.cidr_block
      port      = "443"
      protocol  = "tcp"
    }
  ]
}

# ==================================================================================
# VPCエンドポイント
# ==================================================================================
#
# SSMは3つ必要
#
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.requester.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.sg_vpc_endpoint.id]
  subnet_ids          = [aws_subnet.requester.id]
  private_dns_enabled = true

  tags = {
    Name = "${local.requester_name}-ec2messages"
  }
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.requester.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.sg_vpc_endpoint.id]
  subnet_ids          = [aws_subnet.requester.id]
  private_dns_enabled = true

  tags = {
    Name = "${local.requester_name}-ssm"
  }
}
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.requester.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.sg_vpc_endpoint.id]
  subnet_ids          = [aws_subnet.requester.id]
  private_dns_enabled = true

  tags = {
    Name = "${local.requester_name}-ssmmessages"
  }
}

#
# S3用のゲートウェイエンドポイント
#
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.requester.id
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = [aws_route_table.requester.id]
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "${local.requester_name}-s3"
  }
}


# ===============================================================================
# IAMロール・ポリシー
# ===============================================================================
#
# 踏み台サーバ用のロール。SSMアクセスと、S3アクセスを許可する。
#
module "role_for_bastion" {
  source = "../modules/iam_role"
  name   = "ssm-role"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:PutObject",
          "s3:GetObject"
        ],
        "Resource" : "*"
      },
    ]
  })
  identifier = "ec2.amazonaws.com"
}

# ================================================================================
# EC2
# ===============================================================================
#
# 踏み台サーバ。
# SSMに非EC2で使う場合、アドバンストインスタンス層を有効化する必要があるが、これは料金が発生するため踏み台はEC2にする。
#
resource "aws_instance" "bastion" {
  ami                    = "ami-0b6e7ccaa7b93e898"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.requester.id
  vpc_security_group_ids = [module.sg_compute.id]
  iam_instance_profile   = module.role_for_bastion.iam_instance_profile.id
  user_data              = file("./scripts/bastion_setup.sh")

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
    iops                  = 3000
    throughput            = 125

    tags = {
      Name = "${local.requester_name}-bastion-volume"
    }
  }

  tags = {
    Name = "${local.requester_name}-bastion"
  }
}
