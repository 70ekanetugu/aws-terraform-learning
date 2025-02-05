output "ecr_web_name" {
  value = aws_ecr_repository.demo_web.name
}

output "ecr_web_registry_url" {
  value = aws_ecr_repository.demo_web.repository_url
}

output "ecr_ap_name" {
  value = aws_ecr_repository.demo_ap.name
}

output "ecr_ap_registry_url" {
  value = aws_ecr_repository.demo_ap.repository_url
}
