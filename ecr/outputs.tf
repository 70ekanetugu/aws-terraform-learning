output "ecr_web_name" {
  value = aws_ecr_repository.demo_web.name
}

output "ecr_web_registry_id" {
  value = aws_ecr_repository.demo_web.registry_id
}

output "ecr_ap_name" {
  value = aws_ecr_repository.demo_ap.name
}

output "ecr_ap_registry_id" {
  value = aws_ecr_repository.demo_ap.registry_id
}
