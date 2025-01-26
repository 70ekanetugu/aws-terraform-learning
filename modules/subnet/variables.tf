# vpcのid
variable "vpc_id" {
  type        = string
  description = "Id of vpc"
}

variable "is_public" {
  type        = bool
  description = "Set to true if the subnet should be public, false otherwise."
  default     = false
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones where subnets will be created."
  default     = ["ap-northeast-1a"]
}

variable "tag_name" {
  type        = string
  description = "Value of Name tag."
  default     = "example-subnet"
}
