variable "vpc_id" {
  type        = string
  description = "Id of vpc"
}

variable "name" {
  type        = string
  description = "Security group name."
}

variable "cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks that are allowed ingress access to the security group."
  default     = ["0.0.0.0/0"]
}

variable "from_port" {
  type        = number
  description = "Inbound port for ingress. 0 allow all port."
  default     = 0
}

variable "to_port" {
  type        = number
  description = "Outbound port for ingress, 0 allow all port."
  default     = 0
}

variable "protocol" {
  type        = string
  description = "Protocol. 'tcp' or 'udp' or '-1'(allow all)"
  default     = "-1"
}
