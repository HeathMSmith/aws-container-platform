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


class AugmentationStatus(StrEnum):
    GENERATED = "generated"
    FALLBACK = "fallback"
    DISABLED = "disabled"


class TradeoffAnalysis(BaseModel):
    model_config = ConfigDict(extra="forbid")

    decision: str = Field(
        description=(
            "Deterministic architecture decision expressed in no more than " "12 words."
        )
    )
    benefit: str = Field(
        description=("One workload-specific benefit sentence of no more than 30 words.")
    )
    tradeoff: str = Field(
        description=(
            "One cost, limitation, or operational-consequence sentence of no "
            "more than 30 words."
        )
    )


class ImplementationStep(BaseModel):
    model_config = ConfigDict(extra="forbid")

    order: int = Field(
        description="Recommended sequence number for the implementation step."
    )
    title: str = Field(description="Short title describing the implementation step.")
    description: str = Field(
        description="Workload-specific guidance for completing the step."
    )


class BedrockAnalysis(BaseModel):
    model_config = ConfigDict(extra="forbid")

    architecture_narrative: str = Field(
        description="Explanation of how the selected AWS components work together."
    )
    tradeoff_analysis: list[TradeoffAnalysis] = Field(
        description="Detailed analysis of deterministic architecture tradeoffs."
    )
    implementation_steps: list[ImplementationStep] = Field(
        description="Ordered guidance for implementing the proposed architecture."
    )
    assumptions: list[str] = Field(
        description="Assumptions inferred from incomplete workload information."
    )
    refinement_questions: list[str] = Field(
        description="Questions that could improve a future recommendation."
    )


class BedrockOutputImplementationStep(BaseModel):
    model_config = ConfigDict(extra="forbid")

    title: str = Field(description="Imperative step title of no more than 10 words.")
    description: str = Field(
        description=(
            "One or two workload-specific implementation sentences totaling "
            "no more than 40 words."
        )
    )


class BedrockOutputTradeoffs(BaseModel):
    model_config = ConfigDict(extra="forbid")

    tradeoff_1: TradeoffAnalysis
    tradeoff_2: TradeoffAnalysis
    tradeoff_3: TradeoffAnalysis


class BedrockOutputImplementationSteps(BaseModel):
    model_config = ConfigDict(extra="forbid")

    step_1: BedrockOutputImplementationStep
    step_2: BedrockOutputImplementationStep
    step_3: BedrockOutputImplementationStep
    step_4: BedrockOutputImplementationStep
    step_5: BedrockOutputImplementationStep


class BedrockOutputAssumptions(BaseModel):
    model_config = ConfigDict(extra="forbid")

    assumption_1: str = Field(
        description="One workload assumption of no more than 25 words."
    )
    assumption_2: str = Field(
        description="One workload assumption of no more than 25 words."
    )
    assumption_3: str = Field(
        description="One workload assumption of no more than 25 words."
    )


class BedrockOutputQuestions(BaseModel):
    model_config = ConfigDict(extra="forbid")

    question_1: str = Field(
        description="One refinement question of no more than 25 words."
    )
    question_2: str = Field(
        description="One refinement question of no more than 25 words."
    )
    question_3: str = Field(
        description="One refinement question of no more than 25 words."
    )


class BedrockOutputAnalysis(BaseModel):
    model_config = ConfigDict(extra="forbid")

    architecture_narrative: str = Field(
        description=(
            "One workload-specific architecture paragraph of no more than "
            "100 words."
        )
    )
    tradeoff_analysis: BedrockOutputTradeoffs
    implementation_steps: BedrockOutputImplementationSteps
    assumptions: BedrockOutputAssumptions
    refinement_questions: BedrockOutputQuestions


class AdvisorAugmentation(BaseModel):
    status: AugmentationStatus = Field(
        description="Outcome of the optional Bedrock augmentation attempt."
    )
    model_id: str | None = Field(
        default=None,
        description="Bedrock model used for the augmentation attempt.",
    )
    analysis: BedrockAnalysis | None = Field(
        default=None,
        description="Generated analysis when Bedrock augmentation succeeds.",
    )


class AdvisorResponse(BaseModel):
    architecture_name: str
    summary: str
    services: list[ServiceRecommendation]
    design: ArchitectureDesign
    well_architected: dict[ArchitecturePriority, WellArchitectedAssessment]
    tradeoffs: list[str]
    next_steps: list[str]
    augmentation: AdvisorAugmentation | None = Field(
        default=None,
        description="Optional Bedrock-generated analysis of the recommendation.",
    )
