variable "name" {
  description = "IAM role name and IAM policy name"
  type        = string
}

variable "policy" {
  description = "IAM policy document"
  type        = string
  #   default = <<JSON
  #   {
  #     "Version": "2012-10-17",
  #     "Statement": [
  #       {
  #         "Effect": "Allow",
  #         "Action": [
  #           "ssm:DescribeInstanceInformation",
  #           "ssm:ListAssociations",
  #           "ssm:ListInstanceAssociations",
  #           "ssm:ListCommandInvocations",
  #           "ssm:ListCommands"
  #         ],
  #         "Resource": "*"
  #       }
  #     ]
  #   }
  #   JSON
}

variable "identifier" {
  description = "An identifier for the IAM role"
  type        = string
}
