from fastapi.testclient import TestClient

from services.advisor.advisor_app.main import app


client = TestClient(app)


def build_request(**overrides):
    payload = {
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
    payload.update(overrides)
    return payload


def service_names(body):
    return {
        recommendation["service"]
        for recommendation in body["services"]
    }


def test_root():
    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {
        "service": "architecture-advisor",
        "status": "running",
    }


def test_health():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_ready():
    response = client.get("/ready")

    assert response.status_code == 200
    assert response.json() == {"status": "ready"}


def test_web_application_returns_structured_architecture():
    response = client.post("/advise", json=build_request())

    assert response.status_code == 200

    body = response.json()

    assert body["architecture_name"] == "AWS Workload Architecture Recommendation"
    assert body["summary"]

    assert "Application Load Balancer" in service_names(body)
    assert "Amazon ECS on AWS Fargate" in service_names(body)

    assert body["design"]["compute"]
    assert body["design"]["networking"]
    assert body["design"]["data"]
    assert body["design"]["security"]
    assert body["design"]["observability"]

    assert set(body["well_architected"]) == {
        "security",
        "reliability",
        "cost_optimization",
    }

    assert body["tradeoffs"]
    assert body["next_steps"]

def test_advisor_response_includes_unset_augmentation():
    response = client.post("/advise", json=build_request())

    assert response.status_code == 200
    assert response.json()["augmentation"] is None


def test_relational_data_recommends_aurora():
    response = client.post(
        "/advise",
        json=build_request(data_requirement="relational"),
    )

    assert response.status_code == 200
    assert "Amazon Aurora" in service_names(response.json())


def test_key_value_data_recommends_dynamodb():
    response = client.post(
        "/advise",
        json=build_request(data_requirement="key_value"),
    )

    assert response.status_code == 200
    assert "Amazon DynamoDB" in service_names(response.json())


def test_object_storage_recommends_s3():
    response = client.post(
        "/advise",
        json=build_request(data_requirement="object_storage"),
    )

    assert response.status_code == 200
    assert "Amazon S3" in service_names(response.json())


def test_no_data_requirement_adds_no_data_service():
    response = client.post(
        "/advise",
        json=build_request(data_requirement="none"),
    )

    assert response.status_code == 200

    services = service_names(response.json())

    assert "Amazon Aurora" not in services
    assert "Amazon DynamoDB" not in services
    assert "Amazon S3" not in services


def test_variable_traffic_recommends_ecs_auto_scaling():
    response = client.post(
        "/advise",
        json=build_request(traffic_pattern="variable"),
    )

    assert response.status_code == 200
    assert "Amazon ECS Service Auto Scaling" in service_names(response.json())


def test_bursty_traffic_recommends_sqs():
    response = client.post(
        "/advise",
        json=build_request(traffic_pattern="bursty"),
    )

    assert response.status_code == 200
    assert "Amazon SQS" in service_names(response.json())


def test_event_driven_workload_recommends_eventbridge_and_sqs():
    response = client.post(
        "/advise",
        json=build_request(
            workload_type="event_driven",
            traffic_pattern="steady",
        ),
    )

    assert response.status_code == 200

    services = service_names(response.json())

    assert "Amazon EventBridge" in services
    assert "Amazon SQS" in services
    assert "Amazon ECS on AWS Fargate" in services


def test_high_availability_produces_multi_az_design():
    response = client.post(
        "/advise",
        json=build_request(availability_requirement="high"),
    )

    assert response.status_code == 200

    body = response.json()

    assert "multiple Availability Zones" in body["design"]["networking"]
    assert any(
        "Multi-AZ" in tradeoff
        for tradeoff in body["tradeoffs"]
    )


def test_only_requested_well_architected_priorities_are_returned():
    response = client.post(
        "/advise",
        json=build_request(
            priorities=[
                "security",
                "performance",
            ]
        ),
    )

    assert response.status_code == 200

    assert set(response.json()["well_architected"]) == {
        "security",
        "performance",
    }


def test_service_recommendations_are_unique():
    response = client.post(
        "/advise",
        json=build_request(
            workload_type="event_driven",
            traffic_pattern="bursty",
        ),
    )

    assert response.status_code == 200

    services = [
        recommendation["service"]
        for recommendation in response.json()["services"]
    ]

    assert len(services) == len(set(services))


def test_advise_rejects_invalid_workload_type():
    response = client.post(
        "/advise",
        json=build_request(workload_type="something_invalid"),
    )

    assert response.status_code == 422


def test_advise_requires_at_least_one_priority():
    response = client.post(
        "/advise",
        json=build_request(priorities=[]),
    )

    assert response.status_code == 422


def test_advise_rejects_more_than_three_priorities():
    response = client.post(
        "/advise",
        json=build_request(
            priorities=[
                "security",
                "reliability",
                "performance",
                "cost_optimization",
            ]
        ),
    )

    assert response.status_code == 422


def test_local_frontend_origin_is_allowed():
    response = client.options(
        "/advise",
        headers={
            "Origin": "http://localhost:8080",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "Content-Type",
        },
    )

    assert response.status_code == 200
    assert response.headers["access-control-allow-origin"] == "http://localhost:8080"
