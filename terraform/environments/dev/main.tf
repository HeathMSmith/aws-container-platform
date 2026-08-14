resource "aws_ecr_repository" "app" {
  name                 = "aws-container-platform"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecs_cluster" "app" {
  name = "aws-container-platform-${var.environment}"
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/aws-container-platform-${var.environment}"
  retention_in_days = 7
}
