from fastapi import FastAPI

app = FastAPI(
    title="AWS Container Platform",
    version="0.1.0"
)

@app.get("/")
def root():
    return {
        "service": "aws-container-platform",
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
