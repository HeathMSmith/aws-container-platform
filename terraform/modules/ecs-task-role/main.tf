data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-${var.environment}-${var.service_name}-ecs-task"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy" "ecs_task" {
  count = var.policy_json != null ? 1 : 0

  name   = "${var.project_name}-${var.environment}-${var.service_name}-ecs-task"
  role   = aws_iam_role.ecs_task.id
  policy = var.policy_json
}
