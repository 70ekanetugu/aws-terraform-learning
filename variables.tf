variable "env" {
  description = "System environment dev | stg | prd | test."
  type        = string
  default     = "test"
}

variable "cidr_block_prefix" {
  type    = string
  default = "10.0"
}

variable "availability_zones" {
  description = "Availability zone list"
  type        = list(string)
  default     = ["ap-northeast-1a"]
}
