variable "ingress_port_and_protocol" {
  description = "Ingress port and protocol pairs. Port that allow TCP, UDP port number. Protocol is 'tcp', 'udp', '-1'."
  type        = list(map(string))
  # default = [{
  #   port = "0" 
  #   protocol = "-1"
  # }]
}

variable "ingress_source" {
  description = "Map have keys 'cidr_ipv4' and 'referenced_sg_id'. Key 'cidr_ipv4' ignore if referenced_security_group_id is set."
  type        = map(string)
  # default = {
  #   cidr_ipv4 = "0.0.0.0/0"
  #   referenced_sg_id = ""
  # }
}

variable "name" {
  description = "For security group. This name also use tags 'Name'."
  type        = string
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}
