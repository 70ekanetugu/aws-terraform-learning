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
