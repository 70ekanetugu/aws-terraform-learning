variable "env" {
  type        = string
  description = "Env name."
}

variable "ingress_allow_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks. "
}

variable "ingress_from_port" {
  type        = string
  description = "Start port number or protocol."
}

variable "ingress_to_port" {
  type        = string
  description = "End port number or protocol."
}

variable "ingress_protocol" {
  type        = string
  description = "Protocol for ingress"
  default     = "tcp"
}

variable "sg_name" {
  type        = string
  description = "Name of security group"
}

variable "vpc_id" {
  type    = string
  default = "Id of VPC"
}
