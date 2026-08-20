from enum import StrEnum

from pydantic import BaseModel, Field


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
    workload_type: WorkloadType
    traffic_pattern: TrafficPattern
    availability_requirement: AvailabilityRequirement
    data_requirement: DataRequirement
    expected_scale: Scale
    priorities: list[ArchitecturePriority] = Field(min_length=1, max_length=3)


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
