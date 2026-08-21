from fastapi import FastAPI

app = FastAPI(
    title="AWS Container Platform",
    version="0.1.0"
)

@app.get(
    "/",
    summary="Get service status",
    description="Return the service name and current running status.",
)
def root():
    return {
        "service": "aws-container-platform",
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
