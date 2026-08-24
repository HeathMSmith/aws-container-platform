resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = var.private_subnet_ids

  security_group_ids = [
    var.vpc_endpoint_security_group_id
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-ecr-api"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = var.private_subnet_ids

  security_group_ids = [
    var.vpc_endpoint_security_group_id
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = var.private_subnet_ids

  security_group_ids = [
    var.vpc_endpoint_security_group_id
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-logs"
  }
}

data "aws_iam_policy_document" "bedrock_runtime_endpoint" {
  count = var.bedrock_runtime_endpoint_enabled ? 1 : 0

  statement {
    sid    = "AllowAdvisorInferenceProfileInvocation"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "bedrock:InvokeModel",
    ]

    resources = [
      var.bedrock_runtime_inference_profile_arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = [var.bedrock_runtime_principal_arn]
    }
  }

  statement {
    sid    = "AllowAdvisorDestinationModelInvocation"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "bedrock:InvokeModel",
    ]

    resources = var.bedrock_runtime_foundation_model_arns

    condition {
      test     = "StringEquals"
      variable = "bedrock:InferenceProfileArn"
      values   = [var.bedrock_runtime_inference_profile_arn]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = [var.bedrock_runtime_principal_arn]
    }
  }
}

resource "aws_vpc_endpoint" "bedrock_runtime" {
  count = var.bedrock_runtime_endpoint_enabled ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [var.private_subnet_ids[0]]

  security_group_ids = [
    var.vpc_endpoint_security_group_id,
  ]

  policy = data.aws_iam_policy_document.bedrock_runtime_endpoint[0].json

  tags = {
    Name = "${var.project_name}-${var.environment}-bedrock-runtime"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    var.private_route_table_id
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-s3"
  }
}
