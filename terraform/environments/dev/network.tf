resource "aws_vpc" "app" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "aws-container-platform-${var.environment}"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "aws-container-platform-${var.environment}-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "aws-container-platform-${var.environment}-public-b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "10.20.11.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "aws-container-platform-${var.environment}-private-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "10.20.12.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "aws-container-platform-${var.environment}-private-b"
  }
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "aws-container-platform-${var.environment}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }

  tags = {
    Name = "aws-container-platform-${var.environment}-public"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "aws-container-platform-${var.environment}-private"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "alb" {
  name        = "aws-container-platform-${var.environment}-alb"
  description = "Security group for the public Application Load Balancer."
  vpc_id      = aws_vpc.app.id

  ingress {
    description = "HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-container-platform-${var.environment}-alb"
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "aws-container-platform-${var.environment}-ecs-tasks"
  description = "Security group for ECS Fargate tasks."
  vpc_id      = aws_vpc.app.id

  ingress {
    description     = "Application traffic from ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-container-platform-${var.environment}-ecs-tasks"
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "aws-container-platform-${var.environment}-vpc-endpoints"
  description = "Allow ECS tasks to access interface VPC endpoints."
  vpc_id      = aws_vpc.app.id

  ingress {
    description     = "HTTPS from ECS tasks"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-container-platform-${var.environment}-vpc-endpoints"
  }
}
