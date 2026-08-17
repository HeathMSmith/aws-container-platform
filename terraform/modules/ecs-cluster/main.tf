resource "aws_ecs_cluster" "app" {
  name = "${var.project_name}-${var.environment}"
}
