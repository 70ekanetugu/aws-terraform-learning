variable "ingress_rule_by_cidr_block" {
  description = "Map have ingress rules. Ingress Port that allow TCP, UDP port number. Protocol is 'tcp', 'udp', '-1'."
  type        = list(map(string))
  default     = []
  # 例). 
  # ingress_rule_by_cidr_block = [{
  #   cidr_ipv4 = "0.0.0.0/0"
  #   port = "-1" # すべて許可の場合は-1
  #   protocol = "-1" # すべて許可の場合は-1
  # }]
}

variable "ingress_rule_by_referenced_sg" {
  description = "Map have ingress rules. Ingress Port that allow TCP, UDP port number. Protocol is 'tcp', 'udp', '-1'."
  type        = list(map(string))
  default     = []
  # 例). 
  # ingress_rule_by_referenced_sg = [{
  #   referenced_sg_id = "" # 許可するセキュリティグループのID
  #   port = "-1" # すべて許可の場合は-1
  #   protocol = "-1" # すべて許可の場合は-1
  # }]
}

variable "name" {
  description = "For security group. This name also use tags 'Name'."
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}
