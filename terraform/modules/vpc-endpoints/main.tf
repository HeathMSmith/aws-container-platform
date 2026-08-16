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
