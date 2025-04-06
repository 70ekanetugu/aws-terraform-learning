locals {
  acceptor_name = "kanetugu-acceptor"
}

# =================================================================================
# Acceptor側のVPC
# ================================================================================
resource "aws_vpc" "acceptor" {
  cidr_block           = "${var.acceptor_cidr_block_prefix}.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.acceptor_name}-vpc"
  }
}

resource "aws_subnet" "acceptor" {
  availability_zone = "${var.region}a"
  cidr_block        = "${var.acceptor_cidr_block_prefix}.0.0/24"
  vpc_id            = aws_vpc.acceptor.id

  tags = {
    Name = "${local.acceptor_name}-private"
  }
}

# RDSをシングルAZ利用する場合でも、サブネットグループは2つ以上のAZ指定が必要なため用意。
resource "aws_subnet" "acceptor_other" {
  availability_zone = "${var.region}c"
  cidr_block        = "${var.acceptor_cidr_block_prefix}.1.0/24"
  vpc_id            = aws_vpc.acceptor.id

  tags = {
    Name = "${local.acceptor_name}-private-other"
  }
}

# =================================================================================
# ルートテーブル
# ================================================================================
#
# privateサブネット用のルートテーブル
#
resource "aws_route_table" "acceptor" {
  vpc_id = aws_vpc.acceptor.id

  tags = {
    Name = "${local.acceptor_name}-private-rtb"
  }
}
resource "aws_route_table_association" "acceptor" {
  subnet_id      = aws_subnet.acceptor.id
  route_table_id = aws_route_table.acceptor.id

  depends_on = [aws_vpc_peering_connection.peering]
}
resource "aws_route_table_association" "acceptor_other" {
  subnet_id      = aws_subnet.acceptor_other.id
  route_table_id = aws_route_table.acceptor.id

  depends_on = [aws_vpc_peering_connection.peering]
}

# =================================================================================
# セキュリティグループ 
# =================================================================================
#
# 踏み台からのSSH用
#
module "sg_ssh" {
  source = "../modules/security_group"
  vpc_id = aws_vpc.acceptor.id
  name   = "${local.acceptor_name}-ssh"

  ingress_rule_by_cidr_block = [
    {
      cidr_ipv4 = aws_vpc.requester.cidr_block
      port      = "22"
      protocol  = "tcp"
    }
  ]
}

#
# DBアクセス用
#
module "sg_postgres" {
  source = "../modules/security_group"
  vpc_id = aws_vpc.acceptor.id
  name   = "${local.acceptor_name}-rds"
  ingress_rule_by_cidr_block = [
    {
      cidr_ipv4 = aws_vpc.requester.cidr_block
      port      = "5432"
      protocol  = "tcp"
    }
  ]
}
module "sg_mysql" {
  source = "../modules/security_group"
  vpc_id = aws_vpc.acceptor.id
  name   = "${local.acceptor_name}-aurora"
  ingress_rule_by_cidr_block = [
    {
      cidr_ipv4 = aws_vpc.requester.cidr_block
      port      = "3306"
      protocol  = "tcp"
    }
  ]
}

# =================================================================================
# Key pair
# =================================================================================
#
# EC2用のSSH鍵ペア。踏み台サーバからacceptor側のEC2にログインするために使用する。
#
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "ec2" {
  key_name   = "${local.acceptor_name}-ec2"
  public_key = tls_private_key.rsa.public_key_openssh

  lifecycle {
    ignore_changes = [key_name]
  }
}

# =================================================================================
# EC2
# =================================================================================
resource "aws_instance" "acceptor" {
  ami                    = "ami-0b6e7ccaa7b93e898" # Amazon Linux 2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.acceptor.id
  vpc_security_group_ids = [module.sg_ssh.id]
  key_name               = aws_key_pair.ec2.key_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
    iops                  = 3000
    throughput            = 125

    tags = {
      Name = "${local.acceptor_name}-ec2-volume"
    }
  }

  tags = {
    Name = "${local.acceptor_name}-ec2"
  }
}


# =================================================================================
# DB
# =================================================================================
#
# RDS for postgres 
#
resource "aws_db_subnet_group" "psql" {
  name       = "${local.acceptor_name}-psql"
  subnet_ids = [aws_subnet.acceptor.id, aws_subnet.acceptor_other.id]

  tags = {
    Name = "${local.acceptor_name}-psql"
  }
}
resource "aws_db_instance" "psql" {
  identifier             = "${local.acceptor_name}-psql"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_subnet_group_name   = aws_db_subnet_group.psql.name
  username               = "postgres"
  password               = "postgresPassword!"
  db_name                = "sample"
  vpc_security_group_ids = [module.sg_postgres.id]
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "${local.acceptor_name}-psql"
  }
}
#
# Aurora for mysql
#
resource "aws_db_subnet_group" "mysql" {
  name       = "${local.acceptor_name}-mysql"
  subnet_ids = [aws_subnet.acceptor.id, aws_subnet.acceptor_other.id]

  tags = {
    Name = "${local.acceptor_name}-mysql"
  }
}

resource "aws_rds_cluster" "mysql" {
  cluster_identifier              = "${local.acceptor_name}-mysql"
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.mysql_aurora.3.08.1"
  master_username                 = "admin"
  master_password                 = "adminPassword!"
  port                            = 3306
  database_name                   = "sample"
  db_subnet_group_name            = aws_db_subnet_group.mysql.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mysql.name
  vpc_security_group_ids          = [module.sg_mysql.id]

  skip_final_snapshot = true
  apply_immediately   = true
}
resource "aws_rds_cluster_parameter_group" "mysql" {
  name        = "${local.acceptor_name}-mysql"
  family      = "aurora-mysql8.0"
  description = "Aurora MySQL parameter group"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name         = "character_set_connection"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_database"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_filesystem"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_results"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_server"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "collation_connection"
    value        = "utf8mb4_general_ci"
    apply_method = "immediate"
  }

  parameter {
    name         = "collation_server"
    value        = "utf8mb4_general_ci"
    apply_method = "immediate"
  }

  parameter {
    name         = "time_zone"
    value        = "Asia/Tokyo"
    apply_method = "immediate"
  }
}
resource "aws_rds_cluster_instance" "mysql" {
  count                = 1
  identifier           = "${local.acceptor_name}-mysql-${count.index}"
  cluster_identifier   = aws_rds_cluster.mysql.id
  instance_class       = "db.t3.medium"
  engine               = "aurora-mysql"
  engine_version       = "8.0.mysql_aurora.3.08.1"
  db_subnet_group_name = aws_db_subnet_group.mysql.name
  publicly_accessible  = false
}
resource "aws_db_parameter_group" "mysql" {
  name        = "${local.acceptor_name}-mysql"
  family      = "aurora-mysql8.0"
  description = "Aurora MySQL parameter group"
}
