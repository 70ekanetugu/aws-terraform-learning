output "dns_name" {
  description = "The DNS name of ALB. This can be used to access the ALB from the internet if it is internet-facing."
  value       = aws_lb.default.dns_name
}

output "target_group_arn" {
  description = "ARN of created ALB. This unique identifier is used to manage and locate resources within AWS."
  value       = aws_lb_target_group.default.arn
}
