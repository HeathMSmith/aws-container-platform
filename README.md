# AWS Container Platform

A production-oriented container platform project built incrementally to demonstrate containerization, AWS container services, infrastructure as code, deployment automation, observability, and platform engineering patterns.

The project begins with a minimal FastAPI service and Docker image, then progressively evolves toward Amazon ECR, Amazon ECS on AWS Fargate, production ECS patterns, self-service platform capabilities, Kubernetes, and Amazon EKS.

## Current Milestone

**Local Container Baseline**

The current implementation provides a minimal FastAPI service packaged as a Docker image and verified locally.

Implemented capabilities:

- Python 3.13 FastAPI application
- Root, health, and readiness endpoints
- Automated endpoint tests with pytest
- Dockerized application runtime
- Dedicated non-root container user
- Explicit container port configuration
- Separate runtime and development dependencies
- Pinned direct dependency versions
- Docker build-context exclusions for development artifacts

AWS infrastructure has not yet been introduced.

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

Build the local container image:

```bash
docker build -t aws-container-platform:local .
```

Run the container:

```bash
docker run --rm \
  --name aws-container-platform \
  -p 8000:8000 \
  aws-container-platform:local
```

Verify the running service:

```bash
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/ready
```

## Container Security

The application runs as a dedicated non-root Linux user inside the container rather than as `root`.

The runtime image contains only application dependencies. Development and test dependencies such as pytest and httpx are intentionally excluded from the production-oriented container image.

## Project Roadmap

The project will evolve incrementally through the following stages:

1. **Docker fundamentals** — in progress
2. **Amazon ECR**
3. **Amazon ECS on AWS Fargate**
4. **Production ECS patterns**
5. **Platform abstraction and self-service delivery**
6. **Kubernetes fundamentals**
7. **Amazon EKS**
8. **ECS vs. EKS architectural comparison**

AWS infrastructure will be managed with Terraform. Deployment automation will later use GitHub Actions with AWS OIDC authentication.

## Design Principles

Development follows several consistent engineering principles:

- Make small, focused changes.
- Verify behavior before and after meaningful changes.
- Keep runtime artifacts minimal.
- Apply least-privilege principles at both the container and AWS layers.
- Inspect Terraform plans before applying infrastructure changes.
- Prefer production-relevant implementation patterns over tutorial shortcuts.
- Treat cost control as an architectural requirement.