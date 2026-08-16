# AWS Container Platform

A production-oriented container platform built incrementally to demonstrate containerization, AWS infrastructure design, infrastructure as code, resilient application delivery, and platform engineering practices.

The project runs a containerized FastAPI service on Amazon ECS using AWS Fargate. Application traffic enters through an Application Load Balancer, while Fargate tasks run across private subnets without public IP addresses. AWS service access required by the tasks is provided through VPC endpoints.

Infrastructure is managed with Terraform using reusable modules and an environment-specific composition layer.

## Current Milestone

**Production-Oriented ECS Platform**

The current implementation provides a working AWS container platform with the following capabilities:

- Python FastAPI application
- Root, health, and readiness endpoints
- Automated endpoint tests with pytest
- Dockerized application runtime
- Dedicated non-root container user
- Separate runtime and development dependencies
- Amazon ECR repository with immutable image tags and scan-on-push
- Amazon ECS cluster running workloads on AWS Fargate
- Two ECS service tasks distributed across private subnets
- Application Load Balancer in public subnets
- ALB target health checks
- Container-level health checks
- ECS deployment circuit breaker with automatic rollback
- Private ECR and CloudWatch Logs connectivity through interface VPC endpoints
- Amazon S3 connectivity through a gateway VPC endpoint
- Modular Terraform infrastructure
- Remote Terraform state

The deployed application image is currently versioned as `v0.1.0`.

## Architecture

The current request path is:

```text
Internet
   |
   v
Application Load Balancer
Public Subnets
   |
   v
ECS Service
   |
   +-------------------+
   |                   |
   v                   v
Fargate Task        Fargate Task
Private Subnet A    Private Subnet B
   |                   |
   +---------+---------+
             |
             v
       VPC Endpoints
       /     |      \
      /      |       \
    ECR   CloudWatch   S3
             Logs
```

The Application Load Balancer is internet-facing and deployed across public subnets. ECS tasks run in private subnets with `assign_public_ip = false`.

The private tasks use VPC endpoints for the AWS services required by the current workload:

- ECR API interface endpoint
- ECR Docker Registry interface endpoint
- CloudWatch Logs interface endpoint
- S3 gateway endpoint

This allows the ECS tasks to retrieve container image layers and send application logs without requiring public IP addresses for those service interactions.

## Application Endpoints

| Endpoint | Purpose |
| --- | --- |
| `GET /` | Returns basic service status |
| `GET /health` | Reports application health |
| `GET /ready` | Reports application readiness |

Example health response:

```json
{
  "status": "healthy"
}
```

## Repository Structure

```text
.
├── app/
│   └── main.py
├── tests/
│   └── test_health.py
├── terraform/
│   ├── environments/
│   │   └── dev/
│   │       ├── alb.tf
│   │       ├── backend.tf
│   │       ├── ecr.tf
│   │       ├── ecs.tf
│   │       ├── endpoints.tf
│   │       ├── network.tf
│   │       ├── outputs.tf
│   │       ├── providers.tf
│   │       └── variables.tf
│   └── modules/
│       ├── alb/
│       ├── ecr/
│       ├── ecs-services/
│       ├── network/
│       └── vpc-endpoints/
├── Dockerfile
├── requirements.txt
├── requirements-dev.txt
└── README.md
```

The `terraform/environments/dev` directory is the Terraform root module for the development environment. It composes reusable child modules from `terraform/modules`.

This separation keeps environment-specific configuration at the composition layer while encapsulating infrastructure implementation within focused modules.

## Terraform Modules

### `network`

Creates the networking foundation for the platform, including:

- VPC
- Public subnets
- Private subnets
- Internet gateway
- Public and private route tables
- Route table associations
- ALB security group
- ECS task security group
- VPC endpoint security group

### `ecr`

Creates the Amazon ECR repository used to store application container images.

Current repository controls include:

- Immutable image tags
- Scan-on-push
- AES-256 encryption

### `alb`

Creates the public Application Load Balancer and associated routing resources:

- Application Load Balancer
- IP-based target group
- HTTP listener
- `/health` target health check

### `ecs-services`

Creates the application runtime and supporting resources:

- ECS cluster
- Fargate task definition
- ECS service
- ECS task execution IAM role
- CloudWatch Logs log group
- Container health check
- Deployment circuit breaker

The service currently maintains two desired Fargate tasks.

### `vpc-endpoints`

Provides private connectivity from the workload subnets to required AWS services:

- Amazon ECR API
- Amazon ECR Docker Registry
- Amazon CloudWatch Logs
- Amazon S3

## Local Development

Create and activate a Python virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install the development dependencies:

```bash
python -m pip install -r requirements-dev.txt
```

Run the application locally:

```bash
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

The service is then available at:

```text
http://127.0.0.1:8000
```

## Testing

Run the automated test suite:

```bash
python -m pytest -v
```

The current tests verify the response status and expected JSON payload for all three application endpoints.

## Docker

Build the application image:

```bash
docker build \
  --platform linux/amd64 \
  -t aws-container-platform:v0.1.0 \
  .
```

Run the container locally:

```bash
docker run --rm \
  --name aws-container-platform \
  -p 8000:8000 \
  aws-container-platform:v0.1.0
```

Verify the running service:

```bash
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/ready
```

## Container Security

The application runs as a dedicated non-root Linux user inside the container rather than as `root`.

The runtime image contains only application dependencies. Development and testing dependencies such as pytest and httpx are intentionally maintained separately in `requirements-dev.txt`.

At the AWS infrastructure layer, ECS tasks run in private subnets without public IP addresses. Security groups restrict traffic between the Application Load Balancer, ECS tasks, and VPC endpoints according to their required communication paths.

## Resilience

The ECS service currently maintains two Fargate tasks.

Application availability is evaluated at multiple layers:

1. The container defines an application health check against `/health`.
2. The Application Load Balancer target group independently checks `/health`.
3. ECS replaces unhealthy tasks to maintain the desired service count.
4. The deployment circuit breaker can automatically roll back a failed ECS deployment.

These controls provide both runtime health detection and deployment-level protection.

## Terraform Workflow

Terraform configuration for the development environment is located in:

```text
terraform/environments/dev
```

Initialize the environment:

```bash
AWS_PROFILE=portfolio terraform \
  -chdir=terraform/environments/dev \
  init
```

Validate the configuration:

```bash
AWS_PROFILE=portfolio terraform \
  -chdir=terraform/environments/dev \
  validate
```

Review proposed infrastructure changes:

```bash
AWS_PROFILE=portfolio terraform \
  -chdir=terraform/environments/dev \
  plan
```

Infrastructure changes are reviewed through Terraform plans before they are applied.

## Project Roadmap

The project is being developed incrementally:

1. **Docker fundamentals** — complete
2. **Amazon ECR** — complete
3. **Amazon ECS on AWS Fargate** — complete
4. **Production-oriented ECS patterns** — in progress
5. **CI/CD with GitHub Actions and AWS OIDC** — next
6. **Platform abstraction and self-service delivery**
7. **Kubernetes fundamentals**
8. **Amazon EKS**
9. **ECS vs. EKS architectural comparison**

Future ECS work will continue improving deployment, security, scalability, and observability before the project progresses into Kubernetes and Amazon EKS.

## Design Principles

Development follows several consistent engineering principles:

- Make small, focused changes.
- Verify behavior before and after meaningful changes.
- Keep runtime artifacts minimal.
- Run application containers as non-root users.
- Keep application workloads out of public subnets.
- Apply least-privilege principles at both the container and AWS layers.
- Inspect Terraform plans before applying infrastructure changes.
- Encapsulate infrastructure concerns in focused Terraform modules.
- Prefer production-relevant implementation patterns over tutorial shortcuts.
- Treat resilience, observability, and cost control as architectural requirements.
