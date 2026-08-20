from app.models import (
    AdvisorRequest,
    AdvisorResponse,
    ArchitectureDesign,
    ArchitecturePriority,
    AvailabilityRequirement,
    DataRequirement,
    ServiceRecommendation,
    TrafficPattern,
    WellArchitectedAssessment,
    WorkloadType,
)


def _service(
    name: str,
    purpose: str,
) -> ServiceRecommendation:
    return ServiceRecommendation(
        service=name,
        purpose=purpose,
    )


def _build_compute_recommendations(
    request: AdvisorRequest,
) -> tuple[list[ServiceRecommendation], str]:
    if request.workload_type == WorkloadType.DATA_PROCESSING:
        return (
            [
                _service(
                    "Amazon ECS on AWS Fargate",
                    "Run containerized processing workers without managing servers.",
                )
            ],
            "Containerized processing workers run on AWS Fargate.",
        )

    if request.workload_type == WorkloadType.EVENT_DRIVEN:
        return (
            [
                _service(
                    "Amazon ECS on AWS Fargate",
                    "Run containerized workers that process asynchronous workloads.",
                ),
                _service(
                    "Amazon EventBridge",
                    "Route application events to downstream processing components.",
                ),
                _service(
                    "Amazon SQS",
                    "Buffer work and decouple event producers from processing workers.",
                ),
            ],
            (
                "Event-driven container workers run on AWS Fargate with "
                "EventBridge routing and SQS buffering."
            ),
        )

    return (
        [
            _service(
                "Application Load Balancer",
                "Distribute application traffic across healthy compute resources.",
            ),
            _service(
                "Amazon ECS on AWS Fargate",
                "Run containerized application workloads without managing servers.",
            ),
        ],
        "Containerized application workloads run on AWS Fargate behind an ALB.",
    )


def _build_data_recommendations(
    request: AdvisorRequest,
) -> tuple[list[ServiceRecommendation], str]:
    if request.data_requirement == DataRequirement.RELATIONAL:
        return (
            [
                _service(
                    "Amazon Aurora",
                    "Provide managed relational storage with high-availability capabilities.",
                )
            ],
            "Amazon Aurora provides the relational persistence layer.",
        )

    if request.data_requirement == DataRequirement.KEY_VALUE:
        return (
            [
                _service(
                    "Amazon DynamoDB",
                    "Provide scalable managed key-value persistence.",
                )
            ],
            "Amazon DynamoDB provides the key-value persistence layer.",
        )

    if request.data_requirement == DataRequirement.OBJECT_STORAGE:
        return (
            [
                _service(
                    "Amazon S3",
                    "Provide durable managed object storage.",
                )
            ],
            "Amazon S3 provides durable object storage.",
        )

    return (
        [],
        "The workload does not require a persistent application data store.",
    )


def _build_networking_design(request: AdvisorRequest) -> str:
    if request.availability_requirement == AvailabilityRequirement.HIGH:
        return (
            "Deploy across multiple Availability Zones with redundant application "
            "tasks and load-balanced ingress."
        )

    return (
        "Use a VPC with public ingress and private application subnets, while "
        "avoiding unnecessary high-availability cost."
    )


def _build_traffic_recommendations(
    request: AdvisorRequest,
) -> tuple[list[ServiceRecommendation], list[str]]:
    services: list[ServiceRecommendation] = []
    tradeoffs: list[str] = []

    if request.traffic_pattern == TrafficPattern.VARIABLE:
        services.append(
            _service(
                "Amazon ECS Service Auto Scaling",
                "Adjust application task capacity as demand changes.",
            )
        )
        tradeoffs.append(
            "Auto scaling improves elasticity but requires appropriate scaling "
            "thresholds and capacity limits."
        )

    elif request.traffic_pattern == TrafficPattern.BURSTY:
        services.append(
            _service(
                "Amazon SQS",
                "Buffer sudden workload spikes where asynchronous processing is appropriate.",
            )
        )
        tradeoffs.append(
            "Queue-based buffering absorbs traffic spikes but introduces asynchronous "
            "processing semantics."
        )

    else:
        tradeoffs.append(
            "Steady capacity is operationally simple but may be less cost-efficient "
            "if demand changes significantly."
        )

    return services, tradeoffs


def _build_well_architected_assessment(
    priority: ArchitecturePriority,
) -> WellArchitectedAssessment:
    assessments = {
        ArchitecturePriority.SECURITY: WellArchitectedAssessment(
            strengths=[
                "Application workloads use dedicated IAM task roles.",
                "The design favors controlled network paths and least privilege.",
            ],
            considerations=[
                "Scope each service policy to only the AWS resources it requires.",
                "Review encryption requirements for data at rest and in transit.",
            ],
        ),
        ArchitecturePriority.RELIABILITY: WellArchitectedAssessment(
            strengths=[
                "Managed AWS services reduce infrastructure failure domains.",
                "Health-aware compute and load balancing support workload recovery.",
            ],
            considerations=[
                "Define recovery objectives and test failure scenarios.",
                "Match data-layer resilience to the workload's recovery requirements.",
            ],
        ),
        ArchitecturePriority.PERFORMANCE: WellArchitectedAssessment(
            strengths=[
                "Managed compute can scale independently from application data services."
            ],
            considerations=[
                "Load test the workload before selecting production scaling thresholds.",
                "Use workload metrics rather than assumptions to tune capacity.",
            ],
        ),
        ArchitecturePriority.COST_OPTIMIZATION: WellArchitectedAssessment(
            strengths=[
                "Managed services reduce infrastructure administration overhead.",
                "Elastic capacity can align compute consumption with demand.",
            ],
            considerations=[
                "High availability and continuously running compute increase baseline cost.",
                "Review service utilization and right-size capacity regularly.",
            ],
        ),
        ArchitecturePriority.OPERATIONAL_EXCELLENCE: WellArchitectedAssessment(
            strengths=[
                "Containerized workloads provide repeatable application deployments.",
                "Infrastructure can be managed through automated delivery workflows.",
            ],
            considerations=[
                "Define operational runbooks for deployment and failure scenarios.",
                "Track application and infrastructure changes through version control.",
            ],
        ),
        ArchitecturePriority.SUSTAINABILITY: WellArchitectedAssessment(
            strengths=[
                "Elastic managed services can reduce persistently idle capacity."
            ],
            considerations=[
                "Right-size resources and remove unnecessary always-on capacity.",
                "Measure utilization before increasing compute allocations.",
            ],
        ),
    }

    return assessments[priority]


def generate_recommendation(request: AdvisorRequest) -> AdvisorResponse:
    compute_services, compute_design = _build_compute_recommendations(request)
    data_services, data_design = _build_data_recommendations(request)
    traffic_services, tradeoffs = _build_traffic_recommendations(request)

    services: list[ServiceRecommendation] = []

    for recommendation in (
        compute_services + data_services + traffic_services
    ):
        if recommendation.service not in {
            existing.service for existing in services
        }:
            services.append(recommendation)

    well_architected = {
        priority: _build_well_architected_assessment(priority)
        for priority in request.priorities
    }

    if request.availability_requirement == AvailabilityRequirement.HIGH:
        tradeoffs.append(
            "Multi-AZ redundancy improves availability but increases baseline cost."
        )

    return AdvisorResponse(
        architecture_name="AWS Workload Architecture Recommendation",
        summary=(
            f"A {request.expected_scale.value}-scale "
            f"{request.workload_type.value.replace('_', ' ')} architecture designed "
            f"for {request.traffic_pattern.value} traffic and "
            f"{request.availability_requirement.value} availability."
        ),
        services=services,
        design=ArchitectureDesign(
            compute=compute_design,
            networking=_build_networking_design(request),
            data=data_design,
            security=(
                "Use dedicated least-privilege ECS task roles, controlled network "
                "paths, TLS, and encryption for workload data."
            ),
            observability=(
                "Centralize application logs, infrastructure metrics, health signals, "
                "and actionable CloudWatch alarms."
            ),
        ),
        well_architected=well_architected,
        tradeoffs=tradeoffs,
        next_steps=[
            "Validate the proposed architecture against workload-specific constraints.",
            "Estimate service costs using expected traffic and storage requirements.",
            "Define recovery, security, and operational requirements before production.",
        ],
    )
