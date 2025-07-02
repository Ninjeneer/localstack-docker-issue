# ECR Repository for File Virus Checker Lambda
resource "aws_ecr_repository" "file_virus_checker" {
  name                 = "fluum-file-virus-checker-${var.env_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true # Allows deletion of repository with images for local dev
}

# ECR Repository Policy
resource "aws_ecr_repository_policy" "file_virus_checker_policy" {
  repository = aws_ecr_repository.file_virus_checker.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LambdaECRImageRetrievalPolicy"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

output "file_virus_checker_repository_url" {
  value = aws_ecr_repository.file_virus_checker.repository_url
}
