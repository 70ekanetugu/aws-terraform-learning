output "repository_name" {
  description = "Created ECR name"
  value       = aws_ecr_repository.demo.name
}

output "repository_arn" {
  description = "Created ECR arn"
  value       = aws_ecr_repository.demo.arn
}
