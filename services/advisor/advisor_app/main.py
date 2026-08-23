import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .advisor import generate_recommendation
from .bedrock import augment_recommendation
from .models import AdvisorRequest, AdvisorResponse

app = FastAPI(
    title="AWS Architecture Advisor",
    version="0.1.0",
)

allowed_origins = [
    origin.strip()
    for origin in os.getenv(
        "ALLOWED_ORIGINS",
        "http://localhost:8080",
    ).split(",")
    if origin.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_methods=["POST"],
    allow_headers=["Content-Type"],
)


@app.get(
    "/",
    summary="Get service status",
    description="Return the service name and current running status.",
)
def root() -> dict[str, str]:
    return {
        "service": "architecture-advisor",
        "status": "running",
    }


@app.get(
    "/health",
    summary="Check service health",
    description="Return the current health status of the service.",
)
def health() -> dict[str, str]:
    return {"status": "healthy"}


@app.get(
    "/ready",
    summary="Check service readiness",
    description="Return whether the service is ready to receive traffic.",
)
def ready() -> dict[str, str]:
    return {"status": "ready"}


@app.post(
    "/advise",
    response_model=AdvisorResponse,
    summary="Generate an architecture recommendation",
    description=(
        "Generate an AWS architecture recommendation from a set of workload "
        "requirements. Each request field uses a predefined set of supported "
        "values. Expand the request Schema or see Schemas → AdvisorRequest "
        "below for the available options."
    ),
)
def advise(request: AdvisorRequest) -> AdvisorResponse:
    recommendation = generate_recommendation(request)
    augmentation = augment_recommendation(
        request,
        recommendation,
    )

    return recommendation.model_copy(
        update={"augmentation": augmentation}
    )
