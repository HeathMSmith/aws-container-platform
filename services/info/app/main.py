from fastapi import FastAPI

app = FastAPI(
    title="AWS Container Platform Info Service",
    version="0.1.0"
)


@app.get(
    "/",
    summary="Get service status",
    description="Return the service name and current running status.",
)
def root():
    return {
        "service": "info",
        "status": "running"
    }


@app.get(
    "/health",
    summary="Check service health",
    description="Return the current health status of the service.",
)
def health():
    return {
        "status": "healthy"
    }


@app.get(
    "/ready",
    summary="Check service readiness",
    description="Return whether the service is ready to receive traffic.",
)
def ready():
    return {
        "status": "ready"
    }


@app.get(
    "/info",
    summary="Get platform information",
    description="Return metadata describing the service, platform, and runtime environment.",
)
def info():
    return {
        "service": "info",
        "platform": "aws-container-platform",
        "runtime": "ecs-fargate"
    }
