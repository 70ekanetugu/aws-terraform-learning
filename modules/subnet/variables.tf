# vpcのid
variable "vpc_id" {}
# publicサブネットの場合trueにする。デフォルトはfalse(=private)
variable "is_public" {
  default = false
}
# 柵ネットを作成するAZ一覧。
variable "availability_zones" {
  type    = list(string)
  default = ["ap-northeast-1a"]
}
# tagのNameキーの値
variable "tag_name" {
  type    = string
  default = "example-subnet"
}
