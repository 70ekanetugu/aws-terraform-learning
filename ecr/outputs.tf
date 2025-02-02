output "repository_ap_arn" {
  description = "Created ECR arn"
  value       = aws_ecr_repository.demo_ap.arn
}

output "repository_ap_name" {
  description = "Created ECR name"
  value       = aws_ecr_repository.demo_ap.name
}

output "repository_web_arn" {
  description = "Created ECR arn"
  value       = aws_ecr_repository.demo_web.arn
}

output "repository_web_name" {
  description = "Created ECR name"
  value       = aws_ecr_repository.demo_web.name
}
