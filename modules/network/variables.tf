variable "cidr_block" {
  type        = string
  description = "Cidr_block of VPC"
}

variable "env" {
  type        = string
  description = "Env name."
}

variable "subnet_count" {
  type        = number
  description = "Subnet count."

  validation {
    condition     = var.subnet_count == 1 || var.subnet_count == 2
    error_message = "Must be 1 or 2"
  }
}
