from fastapi import FastAPI

app = FastAPI(
    title="AWS Container Platform Info Service",
    version="0.1.0"
)


@app.get("/")
def root():
    return {
        "service": "info",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.get("/ready")
def ready():
    return {
        "status": "ready"
    }


@app.get("/info")
def info():
    return {
        "service": "info",
        "platform": "aws-container-platform",
        "runtime": "ecs-fargate"
    }
