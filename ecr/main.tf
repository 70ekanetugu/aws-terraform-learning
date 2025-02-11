resource "aws_ecr_repository" "demo_front" {
  name         = "demo-front"
  force_delete = true

  tags = {
    Name = "demo-front"
  }
}

resource "aws_ecr_lifecycle_policy" "demo_front" {
  repository = aws_ecr_repository.demo_front.name

  policy = <<JSON
  {
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 2 release tagged images",
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
  JSON
}

resource "aws_ecr_repository" "demo_backend" {
  name         = "demo-backend"
  force_delete = true

  tags = {
    Name = "demo-backend"
  }
}

resource "aws_ecr_lifecycle_policy" "demo_backend" {
  repository = aws_ecr_repository.demo_backend.name

  policy = <<JSON
  {
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 2 release tagged images",
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
  JSON
}
