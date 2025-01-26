output "alb_dns_name" {
  description = "The DNS name of ALB. This can be used to access the ALB from the internet if it is internet-facing."
  value       = aws_lb.default.dns_name
}
