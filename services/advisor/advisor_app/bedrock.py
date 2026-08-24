import json
import logging
import os
import time
from dataclasses import dataclass
from typing import Any

import boto3
from botocore.config import Config
from botocore.exceptions import BotoCoreError, ClientError
from pydantic import ValidationError

from .models import (
    AdvisorAugmentation,
    AdvisorRequest,
    AdvisorResponse,
    AugmentationStatus,
    BedrockAnalysis,
)

DEFAULT_MODEL_ID = "us.anthropic.claude-haiku-4-5-20251001-v1:0"
DEFAULT_REGION = "us-east-1"
MAX_OUTPUT_TOKENS = 2000

logger = logging.getLogger(__name__)
_clients: dict[str, Any] = {}


@dataclass(frozen=True)
class BedrockSettings:
    enabled: bool
    model_id: str
    region: str

    @classmethod
    def from_environment(cls) -> "BedrockSettings":
        enabled = os.getenv("BEDROCK_ENABLED", "false").strip().lower() in {
            "1",
            "true",
            "yes",
            "on",
        }
        model_id = os.getenv("BEDROCK_MODEL_ID", DEFAULT_MODEL_ID)
        region = (
            os.getenv("AWS_REGION")
            or os.getenv("AWS_DEFAULT_REGION")
            or DEFAULT_REGION
        )
        return cls(
            enabled=enabled,
            model_id=model_id,
            region=region,
        )


def _get_client(region: str) -> Any:
    if region not in _clients:
        _clients[region] = boto3.client(
            "bedrock-runtime",
            region_name=region,
            config=Config(
                connect_timeout=2,
                read_timeout=30,
                tcp_keepalive=True,
                retries={
                    "mode": "standard",
                    "total_max_attempts": 2,
                },
            ),
        )
    return _clients[region]


def _build_output_config() -> dict[str, Any]:
    schema = json.dumps(
        BedrockAnalysis.model_json_schema(),
        separators=(",", ":"),
    )

    return {
        "textFormat": {
            "type": "json_schema",
            "structure": {
                "jsonSchema": {
                    "schema": schema,
                    "name": "advisor_analysis",
                    "description": (
                        "Workload-specific analysis of the deterministic "
                        "AWS architecture recommendation."
                    ),
                }
            },
        }
    }


def _build_prompt(
    request: AdvisorRequest,
    recommendation: AdvisorResponse,
) -> str:
    return json.dumps(
        {
            "instructions": [
                (
                    "Populate every field in the configured output schema. "
                    "Keep each section concise and workload-specific."
                ),
                (
                    "The deterministic recommendation is authoritative. "
                    "Do not add, remove, or replace its AWS services or "
                    "architecture decisions."
                ),
                (
                    "Explain the supplied design, its workload-specific "
                    "benefits and tradeoffs, practical implementation steps, "
                    "assumptions, and useful refinement questions."
                ),
            ],
            "workload_request": request.model_dump(mode="json"),
            "deterministic_recommendation": recommendation.model_dump(
                mode="json",
                exclude={"augmentation"},
            ),
        },
        separators=(",", ":"),
    )


def _extract_analysis(response: dict[str, Any]) -> BedrockAnalysis:
    stop_reason = response.get("stopReason")

    if stop_reason != "end_turn":
        raise ValueError(
            f"Bedrock stopped generation with reason {stop_reason!r}."
        )

    content = response["output"]["message"]["content"]
    generated_text = "".join(
        block["text"]
        for block in content
        if isinstance(block, dict) and "text" in block
    )

    if not generated_text:
        raise ValueError("Bedrock response did not contain generated text.")

    return BedrockAnalysis.model_validate_json(generated_text)


def _fallback(model_id: str) -> AdvisorAugmentation:
    return AdvisorAugmentation(
        status=AugmentationStatus.FALLBACK,
        model_id=model_id,
        analysis=None,
    )


def augment_recommendation(
    request: AdvisorRequest,
    recommendation: AdvisorResponse,
    *,
    settings: BedrockSettings | None = None,
    client: Any | None = None,
) -> AdvisorAugmentation:
    resolved_settings = settings or BedrockSettings.from_environment()

    if not resolved_settings.enabled:
        return AdvisorAugmentation(
            status=AugmentationStatus.DISABLED,
            model_id=None,
            analysis=None,
        )

    started_at = time.monotonic()
    response: dict[str, Any] | None = None

    try:
        runtime_client = client or _get_client(resolved_settings.region)
        response = runtime_client.converse(
            modelId=resolved_settings.model_id,
            system=[
                {
                    "text": (
                        "You are an AWS architecture analyst. Enrich the "
                        "authoritative deterministic recommendation without "
                        "changing its selected services or core design."
                    )
                }
            ],
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "text": _build_prompt(
                                request,
                                recommendation,
                            )
                        }
                    ],
                }
            ],
            inferenceConfig={
                "maxTokens": MAX_OUTPUT_TOKENS,
                "temperature": 0.2,
            },
            outputConfig=_build_output_config(),
        )
        analysis = _extract_analysis(response)
        elapsed_ms = round((time.monotonic() - started_at) * 1000)
        usage = response.get("usage", {})

        logger.info(
            (
                "Bedrock augmentation generated: model_id=%s "
                "input_tokens=%s output_tokens=%s elapsed_ms=%s"
            ),
            resolved_settings.model_id,
            usage.get("inputTokens"),
            usage.get("outputTokens"),
            elapsed_ms,
        )

        return AdvisorAugmentation(
            status=AugmentationStatus.GENERATED,
            model_id=resolved_settings.model_id,
            analysis=analysis,
        )
    except ClientError as error:
        metadata = error.response.get("ResponseMetadata", {})
        elapsed_ms = round((time.monotonic() - started_at) * 1000)
        logger.warning(
            (
                "Bedrock augmentation failed: model_id=%s "
                "error_code=%s request_id=%s elapsed_ms=%s"
            ),
            resolved_settings.model_id,
            error.response.get("Error", {}).get("Code"),
            metadata.get("RequestId"),
            elapsed_ms,
        )
    except BotoCoreError as error:
        elapsed_ms = round((time.monotonic() - started_at) * 1000)
        logger.warning(
            (
                "Bedrock client failure: model_id=%s "
                "error_type=%s elapsed_ms=%s"
            ),
            resolved_settings.model_id,
            type(error).__name__,
            elapsed_ms,
        )
    except ValidationError as error:
        elapsed_ms = round((time.monotonic() - started_at) * 1000)
        response_data = response if isinstance(response, dict) else {}
        usage = response_data.get("usage", {})
        validation_errors = [
            {
                "type": item["type"],
                "location": list(item["loc"]),
            }
            for item in error.errors(
                include_input=False,
                include_url=False,
            )
        ]
        logger.warning(
            (
                "Bedrock response rejected: model_id=%s "
                "error_type=%s stop_reason=%s output_tokens=%s "
                "validation_errors=%s elapsed_ms=%s"
            ),
            resolved_settings.model_id,
            type(error).__name__,
            response_data.get("stopReason"),
            usage.get("outputTokens"),
            validation_errors,
            elapsed_ms,
        )
    except (KeyError, TypeError, ValueError) as error:
        elapsed_ms = round((time.monotonic() - started_at) * 1000)
        response_data = response if isinstance(response, dict) else {}
        usage = response_data.get("usage", {})
        logger.warning(
            (
                "Bedrock response rejected: model_id=%s "
                "error_type=%s stop_reason=%s output_tokens=%s "
                "elapsed_ms=%s"
            ),
            resolved_settings.model_id,
            type(error).__name__,
            response_data.get("stopReason"),
            usage.get("outputTokens"),
            elapsed_ms,
        )
    except Exception as error:
        elapsed_ms = round((time.monotonic() - started_at) * 1000)
        logger.exception(
            (
                "Unexpected Bedrock augmentation failure: model_id=%s "
                "error_type=%s elapsed_ms=%s"
            ),
            resolved_settings.model_id,
            type(error).__name__,
            elapsed_ms,
        )

    return _fallback(resolved_settings.model_id)
