from fastapi import FastAPI

from .advisor import generate_recommendation
from .models import AdvisorRequest, AdvisorResponse


app = FastAPI(
    title="AWS Architecture Advisor",
    version="0.1.0",
)


@app.get("/")
def root() -> dict[str, str]:
    return {
        "service": "architecture-advisor",
        "status": "running",
    }


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "healthy"}


@app.get("/ready")
def ready() -> dict[str, str]:
    return {"status": "ready"}


@app.post("/advise", response_model=AdvisorResponse)
def advise(request: AdvisorRequest) -> AdvisorResponse:
    return generate_recommendation(request)
