output "id" {
  description = "The unique identifier of the security group created by this module."
  value       = aws_security_group.default.id
}
