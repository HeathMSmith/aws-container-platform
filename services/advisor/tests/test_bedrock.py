import json

from botocore.exceptions import ClientError
from botocore.session import Session
from botocore.validate import validate_parameters

from services.advisor.advisor_app.advisor import generate_recommendation
from services.advisor.advisor_app.bedrock import (
    BedrockSettings,
    augment_recommendation,
)
from services.advisor.advisor_app.models import (
    AdvisorRequest,
    AugmentationStatus,
    BedrockOutputAnalysis,
)


MODEL_ID = "us.anthropic.claude-haiku-4-5-20251001-v1:0"


def build_request() -> AdvisorRequest:
    return AdvisorRequest(
        workload_type="web_application",
        traffic_pattern="variable",
        availability_requirement="high",
        data_requirement="relational",
        expected_scale="medium",
        priorities=[
            "security",
            "reliability",
            "cost_optimization",
        ],
    )


def valid_analysis() -> dict:
    return {
        "architecture_narrative": (
            "Requests enter through the load balancer and are processed by "
            "containerized workloads running on AWS Fargate."
        ),
        "tradeoff_analysis": {
            "tradeoff_1": {
                "decision": "Run application containers on AWS Fargate.",
                "benefit": "The team does not manage EC2 instances.",
                "tradeoff": (
                    "Continuously running tasks create baseline compute cost."
                ),
            },
            "tradeoff_2": {
                "decision": "Deploy tasks across multiple Availability Zones.",
                "benefit": "The service remains available during an AZ failure.",
                "tradeoff": "Redundant capacity increases baseline cost.",
            },
            "tradeoff_3": {
                "decision": "Route requests through an Application Load Balancer.",
                "benefit": "Health checks direct traffic toward healthy tasks.",
                "tradeoff": "The load balancer adds cost and configuration.",
            },
        },
        "implementation_steps": {
            "step_1": {
                "title": "Create the network foundation",
                "description": (
                    "Deploy public ingress and private application subnets."
                ),
            },
            "step_2": {
                "title": "Configure task IAM roles",
                "description": (
                    "Grant each workload only the AWS permissions it requires."
                ),
            },
            "step_3": {
                "title": "Register the task definition",
                "description": (
                    "Configure the container image, resources, and health check."
                ),
            },
            "step_4": {
                "title": "Deploy the ECS service",
                "description": (
                    "Run redundant Fargate tasks across Availability Zones."
                ),
            },
            "step_5": {
                "title": "Configure monitoring and alarms",
                "description": (
                    "Collect application logs and alert on unhealthy behavior."
                ),
            },
        },
        "assumptions": {
            "assumption_1": "The workload can run in Linux containers.",
            "assumption_2": "The application exposes an HTTP health endpoint.",
            "assumption_3": "Traffic can enter through a load balancer.",
        },
        "refinement_questions": {
            "question_1": (
                "What recovery time objective does the workload require?"
            ),
            "question_2": "What peak request rate must the service support?",
            "question_3": "Does the workload require persistent storage?",
        },
    }


class FakeBedrockClient:
    def __init__(
        self,
        *,
        response: dict | None = None,
        error: Exception | None = None,
    ):
        self.response = response
        self.error = error
        self.calls: list[dict] = []

    def converse(self, **kwargs):
        self.calls.append(kwargs)

        if self.error:
            raise self.error

        return self.response


class FailIfCalledClient:
    def converse(self, **kwargs):
        raise AssertionError("Disabled Bedrock must not call the SDK client.")


def enabled_settings() -> BedrockSettings:
    return BedrockSettings(
        enabled=True,
        model_id=MODEL_ID,
        region="us-east-1",
    )


def test_disabled_augmentation_does_not_call_bedrock():
    request = build_request()
    recommendation = generate_recommendation(request)

    result = augment_recommendation(
        request,
        recommendation,
        settings=BedrockSettings(
            enabled=False,
            model_id=MODEL_ID,
            region="us-east-1",
        ),
        client=FailIfCalledClient(),
    )

    assert result.status == AugmentationStatus.DISABLED
    assert result.model_id is None
    assert result.analysis is None


def test_valid_bedrock_response_returns_generated_analysis():
    request = build_request()
    recommendation = generate_recommendation(request)
    client = FakeBedrockClient(
        response={
            "output": {
                "message": {
                    "content": [
                        {
                            "text": json.dumps(valid_analysis()),
                        }
                    ]
                }
            },
            "stopReason": "end_turn",
            "usage": {
                "inputTokens": 900,
                "outputTokens": 500,
            },
        }
    )

    result = augment_recommendation(
        request,
        recommendation,
        settings=enabled_settings(),
        client=client,
    )

    assert result.status == AugmentationStatus.GENERATED
    assert result.model_id == MODEL_ID
    assert result.analysis is not None
    assert result.analysis.architecture_narrative
    assert len(result.analysis.tradeoff_analysis) == 3
    assert len(result.analysis.implementation_steps) == 5
    assert [
        step.order
        for step in result.analysis.implementation_steps
    ] == [1, 2, 3, 4, 5]
    assert len(result.analysis.assumptions) == 3
    assert len(result.analysis.refinement_questions) == 3
    assert len(client.calls) == 1

    call = client.calls[0]
    converse_shape = (
        Session()
        .get_service_model("bedrock-runtime")
        .operation_model("Converse")
        .input_shape
    )
    validate_parameters(call, converse_shape)

    assert call["modelId"] == MODEL_ID
    assert call["inferenceConfig"] == {
        "maxTokens": 2000,
        "temperature": 0.2,
    }

    prompt = json.loads(call["messages"][0]["content"][0]["text"])
    service_names = {
        service["service"]
        for service in prompt["deterministic_recommendation"]["services"]
    }
    assert "Amazon ECS on AWS Fargate" in service_names
    assert "output_schema" not in prompt

    text_format = call["outputConfig"]["textFormat"]
    assert text_format["type"] == "json_schema"

    schema_config = text_format["structure"]["jsonSchema"]
    assert schema_config["name"] == "advisor_analysis"
    assert json.loads(schema_config["schema"]) == (
    BedrockOutputAnalysis.model_json_schema()
     )


def test_max_tokens_response_returns_fallback():
    request = build_request()
    recommendation = generate_recommendation(request)
    client = FakeBedrockClient(
        response={
            "output": {
                "message": {
                    "content": [
                        {
                            "text": json.dumps(valid_analysis()),
                        }
                    ]
                }
            },
            "stopReason": "max_tokens",
            "usage": {
                "outputTokens": 2000,
            },
        }
    )

    result = augment_recommendation(
        request,
        recommendation,
        settings=enabled_settings(),
        client=client,
    )

    assert result.status == AugmentationStatus.FALLBACK
    assert result.model_id == MODEL_ID
    assert result.analysis is None


def test_malformed_bedrock_json_returns_fallback():
    request = build_request()
    recommendation = generate_recommendation(request)
    client = FakeBedrockClient(
        response={
            "output": {
                "message": {
                    "content": [
                        {
                            "text": "This is not JSON.",
                        }
                    ]
                }
            },
            "stopReason": "end_turn",
        }
    )

    result = augment_recommendation(
        request,
        recommendation,
        settings=enabled_settings(),
        client=client,
    )

    assert result.status == AugmentationStatus.FALLBACK
    assert result.model_id == MODEL_ID
    assert result.analysis is None


def test_invalid_bedrock_schema_returns_fallback():
    request = build_request()
    recommendation = generate_recommendation(request)
    client = FakeBedrockClient(
        response={
            "output": {
                "message": {
                    "content": [
                        {
                            "text": json.dumps(
                                {
                                    "architecture_narrative": (
                                        "Incomplete response."
                                    )
                                }
                            ),
                        }
                    ]
                }
            },
            "stopReason": "end_turn",
        }
    )

    result = augment_recommendation(
        request,
        recommendation,
        settings=enabled_settings(),
        client=client,
    )

    assert result.status == AugmentationStatus.FALLBACK
    assert result.analysis is None


def test_bedrock_client_error_returns_fallback():
    request = build_request()
    recommendation = generate_recommendation(request)
    client = FakeBedrockClient(
        error=ClientError(
            {
                "Error": {
                    "Code": "ThrottlingException",
                    "Message": "Rate exceeded.",
                },
                "ResponseMetadata": {
                    "RequestId": "test-request-id",
                },
            },
            "Converse",
        )
    )

    result = augment_recommendation(
        request,
        recommendation,
        settings=enabled_settings(),
        client=client,
    )

    assert result.status == AugmentationStatus.FALLBACK
    assert result.model_id == MODEL_ID
    assert result.analysis is None


def test_bedrock_output_schema_avoids_unsupported_constraints():
    unsupported_keywords = {
        "minLength",
        "maxLength",
        "minItems",
        "maxItems",
        "minimum",
        "maximum",
    }
    found_keywords: set[str] = set()

    def inspect_schema(value):
        if isinstance(value, dict):
            found_keywords.update(unsupported_keywords.intersection(value))
            for nested_value in value.values():
                inspect_schema(nested_value)
        elif isinstance(value, list):
            for nested_value in value:
                inspect_schema(nested_value)

    inspect_schema(BedrockOutputAnalysis.model_json_schema())

    assert found_keywords == set()
