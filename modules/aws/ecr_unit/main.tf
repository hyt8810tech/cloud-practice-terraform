resource "aws_ecr_repository" "main" {
  image_tag_mutability = var.image_tag_mutability
  name                 = var.name
}
resource "aws_ecr_lifecycle_policy" "retain_latest_images" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "最新の3世代のイメージのみを保持"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.retained_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
