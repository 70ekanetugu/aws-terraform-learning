resource "aws_ecr_repository" "demo" {
  name = "terraform-demo"

  tags = {
    Name = "terraform-demo"
  }
}

resource "aws_ecr_lifecycle_policy" "demo" {
  repository = aws_ecr_repository.demo.name

  policy = <<EOF
  {
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 2 release tagged images.",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["release"],
                "countType": "imageCountMoreThan",
                "countNumber": 2
            },
            "action": {
                "type": "expire"
            }
        }
    ]
  }
  EOF
}
