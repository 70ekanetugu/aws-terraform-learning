variable "name" {
  type        = string
  description = "IAM role name and IAM policy name"
}

variable "policy" {
  type        = string
  description = "Policy document"
}

variable "identifier" {
  type        = string
  description = "AWS service identifer associates the IAM role"
}
