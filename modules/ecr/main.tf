resource "aws_ecr_repository" "ecr_repository" {
  name = "${var.name}-ecr-repo"

  #a tag can never be overwritten, so a git SHA always means one exact image
  image_tag_mutability = "IMMUTABLE"

  # destroy after every session, and Terraform can't delete a repository that still has images without this
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repository.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 5 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}