output "public_alb_dns" {
  description = "DNS name of public subnet ALB"
  value       = aws_lb.front.dns_name
}
