variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "requester_cidr_block_prefix" {
  type    = string
  default = "10.1"
}

variable "acceptor_cidr_block_prefix" {
  type    = string
  default = "10.2"
}

# 本来なら、ssh鍵ペアはterraform管理外(コンソールなど)で作成し、以下のように名前だけvariableとしt渡して使用するのが良い。
# variable "key_pair_name" {
#   description = "SSH key pair name"
#   type = string
#   default = "vpc-peering-for-ec2"
# }
