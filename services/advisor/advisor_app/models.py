from enum import StrEnum

from pydantic import BaseModel, ConfigDict, Field


class WorkloadType(StrEnum):
    WEB_APPLICATION = "web_application"
    API = "api"
    DATA_PROCESSING = "data_processing"
    EVENT_DRIVEN = "event_driven"


class TrafficPattern(StrEnum):
    STEADY = "steady"
    VARIABLE = "variable"
    BURSTY = "bursty"


class AvailabilityRequirement(StrEnum):
    STANDARD = "standard"
    HIGH = "high"


class DataRequirement(StrEnum):
    NONE = "none"
    RELATIONAL = "relational"
    KEY_VALUE = "key_value"
    OBJECT_STORAGE = "object_storage"


class Scale(StrEnum):
    SMALL = "small"
    MEDIUM = "medium"
    LARGE = "large"


class ArchitecturePriority(StrEnum):
    SECURITY = "security"
    RELIABILITY = "reliability"
    PERFORMANCE = "performance"
    COST_OPTIMIZATION = "cost_optimization"
    OPERATIONAL_EXCELLENCE = "operational_excellence"
    SUSTAINABILITY = "sustainability"


class AdvisorRequest(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "workload_type": "web_application",
                "traffic_pattern": "variable",
                "availability_requirement": "high",
                "data_requirement": "relational",
                "expected_scale": "medium",
                "priorities": [
                    "security",
                    "reliability",
                    "cost_optimization",
                ],
            }
        }
    )

    workload_type: WorkloadType = Field(
        description="Type of workload the architecture needs to support."
    )
    traffic_pattern: TrafficPattern = Field(
        description="Expected pattern of incoming workload demand."
    )
    availability_requirement: AvailabilityRequirement = Field(
        description="Required level of workload availability."
    )
    data_requirement: DataRequirement = Field(
        description="Primary persistence requirement for the workload."
    )
    expected_scale: Scale = Field(
        description="Expected relative scale of the workload."
    )
    priorities: list[ArchitecturePriority] = Field(
        min_length=1,
        max_length=3,
        description=(
            "Select between one and three AWS Well-Architected priorities "
            "to emphasize in the recommendation."
        ),
    )


class ServiceRecommendation(BaseModel):
    service: str
    purpose: str


class ArchitectureDesign(BaseModel):
    compute: str
    networking: str
    data: str
    security: str
    observability: str


class WellArchitectedAssessment(BaseModel):
    strengths: list[str]
    considerations: list[str]


class AdvisorResponse(BaseModel):
    architecture_name: str
    summary: str
    services: list[ServiceRecommendation]
    design: ArchitectureDesign
    well_architected: dict[ArchitecturePriority, WellArchitectedAssessment]
    tradeoffs: list[str]
    next_steps: list[str]
