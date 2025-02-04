resource "aws_ecr_repository" "demo_web" {
  name         = "terraform-demo-web"
  force_delete = true

  tags = {
    Name = "terraform-demo"
  }
}

resource "aws_ecr_lifecycle_policy" "demo_web" {
  repository = aws_ecr_repository.demo_web.name

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

resource "aws_ecr_repository" "demo_ap" {
  name         = "terraform-demo-ap"
  force_delete = true

  tags = {
    Name = "terraform-demo"
  }
}

resource "aws_ecr_lifecycle_policy" "demo_ap" {
  repository = aws_ecr_repository.demo_ap.name

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
