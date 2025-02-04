output "iam_role_arn" {
  description = "Created ARN of IAM role"
  value       = aws_iam_role.default.arn
}

output "iam_role_name" {
  description = "Created name of IAM role"
  value       = aws_iam_role.default.name
}
