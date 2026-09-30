# Operational Runbook

## Scope and intended audience

This runbook is for engineers deploying and operating the DEV and PROD environments defined in this repository. It describes checked-in configuration, not evidence that either environment is currently deployed or healthy. Confirm the account, environment, effective Terraform inputs, and running resources before acting. Historical deployment observations in the root README are not a live inventory.

Workflow instructions below describe existing automation. Additional diagnostic steps are operator guidance; they have not been exercised against live infrastructure as part of writing this document. Operator identities, approval rules, and several recovery policies remain unresolved at the end of this runbook.

## Architecture and service overview

API, Info, and Advisor run as separate ECS services on Fargate in private subnets without public IP addresses. Each environment shares a VPC, ECS cluster, public Application Load Balancer (ALB), execution role, and networking. Each service has its own task definition, task role, target group, DNS record, log group, autoscaling policy, and alarms.

The ALB redirects HTTP to HTTPS and routes by hostname to HTTP port 8000 on the tasks. Unknown hostnames receive a fixed 404. The ALB TLS certificate uses `*.container.hmsdev.click` with ACM DNS validation in the existing public `hmsdev.click` Route 53 zone.

Public and private subnets span two Availability Zones. Private tasks use ECR API, ECR registry, and CloudWatch Logs interface endpoints plus an S3 gateway endpoint; there is no NAT gateway or general outbound internet route. Task security groups allow application ingress from the ALB on port 8000 and outbound HTTPS. AWS service traffic uses the configured VPC endpoints, including the S3 gateway endpoint. The security-group application port is hardcoded to 8000 even though task configuration exposes a port variable.

Advisor also has an S3/CloudFront frontend with a separate ACM certificate and generated `config.js`. Bedrock augmentation is enabled by default. Its conditional Runtime endpoint is placed in the first private subnet only, with invocation permissions restricted through the endpoint and Advisor task-role policies.

Sources: environment composition in [DEV](../terraform/environments/dev/main.tf) and [PROD](../terraform/environments/prod/main.tf), [network](../terraform/modules/network/main.tf), [VPC endpoints](../terraform/modules/vpc-endpoints/main.tf), [ALB](../terraform/modules/alb/main.tf), [TLS](../terraform/modules/tls/main.tf), and [frontend](../terraform/modules/static-frontend/main.tf).

## Environment and hostname conventions

Both environments default to `us-east-1` and enable all three services. The cluster and ALB names are `aws-container-platform-{environment}`. ECS services and task-definition families are `aws-container-platform-{environment}-{service}`, where service is `api`, `info`, or `advisor`.

| HTTPS destination | DEV | PROD |
| --- | --- | --- |
| API | `api-dev.container.hmsdev.click` | `api.container.hmsdev.click` |
| Info | `info-dev.container.hmsdev.click` | `info.container.hmsdev.click` |
| Advisor API | `advisor-dev.container.hmsdev.click` | `advisor.container.hmsdev.click` |
| Advisor frontend | `advisor-dev.hmsdev.click` | `advisor.hmsdev.click` |

| Default per service | DEV | PROD |
| --- | --- | --- |
| CPU units / memory MiB | 256 / 512 | 512 / 1024 |
| Initial desired tasks | 2 | 2 |
| Autoscaling minimum–maximum | 2–4 | 2–6 |
| Log retention | 7 days | 30 days |

CPU target tracking targets 60%, with 300-second scale-in and 60-second scale-out cooldowns. Terraform ignores subsequent ECS `desired_count` changes so autoscaling can manage capacity; changing that variable alone is not an operational resize procedure.

Use [DEV defaults](../terraform/environments/dev/variables.tf), [PROD defaults](../terraform/environments/prod/variables.tf), and environment outputs ([DEV](../terraform/environments/dev/outputs.tf), [PROD](../terraform/environments/prod/outputs.tf)) to resolve effective names and images rather than inferring task revisions or resource IDs.

## Deployment prerequisites

- Identify the intended source revision, environment, complete service set, and image tags. Confirm operator authorization and coordinate against concurrent operations; the repository does not define deployment approvals or complete serialization.
- Ensure the existing Route 53 zone, Terraform state bucket, and shared ECR repositories are available. Environment state uses `hms-terraform-state-portfolio` with keys `container-platform/dev/terraform.tfstate` and `container-platform/prod/terraform.tfstate`, encryption, and S3 lockfiles. The [ECR foundation](../terraform/foundation/ecr/main.tf) has separate state and includes the three service repositories plus the legacy `aws-container-platform` repository.
- Confirm GitHub OIDC configuration and workflow variables: `AWS_ROLE_ARN` for infrastructure, `AWS_ECR_PUBLISHER_ROLE_ARN` for publishing, and `AWS_REGION`. Infrastructure workflows select the GitHub environment `dev` or `prod`. Role permissions, trust policies, and environment protection rules are external prerequisites, not verified by repository code.
- Resolve alarm notification configuration. Workflows pass secret `ALARM_NOTIFICATION_EMAIL` to Terraform. The subscription is conditional on a non-null `alarm_notification_email`; do not assume an absent secret becomes null or that delivery is configured and confirmed.
- Confirm the configured Bedrock inference profile/model is usable in the target account when augmentation is enabled.

The workflows pin Terraform `1.15.3`. Local inspection examples require Terraform configured for the correct backend and authorized AWS access. Do not publish state contents or saved plans as incident evidence.

## Deployment procedure

1. Run or review [CI](../.github/workflows/ci.yml) for the intended revision. It runs application tests, builds all three containers, and checks Terraform formatting and validation; it does not establish runtime health.
2. If a new image is needed, dispatch [ECR Image Publish](../.github/workflows/ecr-publish.yml) for the selected service and source revision, leaving `release_tag` empty to build. Automatic publishing on matching `main` changes covers API only; Info and Advisor use manual dispatch. Builds publish the workflow Git SHA tag to `aws-container-platform-api`, `aws-container-platform-info`, or `aws-container-platform-advisor`.
3. To assign a release name, dispatch the same workflow with the service, an existing `source_sha`, and an unused `release_tag`. It promotes the existing manifest and verifies matching digests. [ECR tags are immutable](../terraform/modules/ecr/main.tf); do not overwrite an existing tag or rebuild merely to rename an image.
4. Set the intended environment's `api_image_tag`, `info_image_tag`, or `advisor_image_tag` through the configuration change process. Publishing does not update these inputs automatically. Review all other changes in the selected revision.
5. Dispatch [Terraform Plan](../.github/workflows/terraform-plan.yml) with the environment and complete desired service set. Review creations, updates, replacements, deletions, and image selections in the plan summary.
6. Once authorized to deploy, dispatch [Terraform Apply](../.github/workflows/terraform-apply.yml) from the same intended revision with the same environment and service selection. It initializes and validates Terraform, runs `terraform plan -no-color -out=tfplan`, then `terraform apply -auto-approve tfplan`. It creates its own plan; it does not apply the earlier Plan workflow's saved artifact or pause after planning for approval.

**Service checkboxes define desired infrastructure, not which services to update.** Deselecting an existing service removes it from the Terraform service map and plans destruction of its resources. Deselecting Advisor also removes its frontend. The workflows require at least one service selected.

## Post-deployment verification

The Apply workflow waits for ECS stability, checks one running task per service, compares its image URI with configuration, checks configured task-definition image URIs, and requests each service's `/health` over HTTPS. It does not verify every task or image digest, explicitly query target health or DNS, or test `/ready`, `/advise`, or the frontend.

For an initialized, authorized local environment, inspect these outputs from the repository root; substitute `prod` for `dev` when appropriate:

```bash
terraform -chdir=terraform/environments/dev output -raw ecs_cluster_name
terraform -chdir=terraform/environments/dev output -json ecs_service_names
terraform -chdir=terraform/environments/dev output -json service_container_images
terraform -chdir=terraform/environments/dev output -json service_urls
terraform -chdir=terraform/environments/dev output -json cloudwatch_log_group_names
terraform -chdir=terraform/environments/dev output -raw advisor_frontend_url
```

The frontend output is only useful when Advisor is enabled. Outputs describe recorded Terraform values; corroborate them with runtime observations.

1. Inspect ECS service events, deployments, desired/running/pending counts, and every running task's revision and image. Compare against the intended release.
2. Inspect each service's attached ALB target group and target-health reason codes. Target group names longer than 32 characters are shortened with a hash; discover them from the ECS service rather than guessing.
3. Request `/`, `/health`, and `/ready` on each configured service hostname. Expect `status: running`, `status: healthy`, and `status: ready` respectively. Info also exposes `GET /info`.
4. Submit a representative `POST /advise` through the Advisor `/docs` interface using its documented request schema. Check the recommendation and `augmentation.status`, not only HTTP status. A request may invoke Bedrock and incur usage charges.
5. Load the frontend, confirm its generated API URL, and submit a recommendation. Check browser network/CORS errors if the API works directly but the UI does not.

For example, a DEV API probe is `curl --fail --show-error https://api-dev.container.hmsdev.click/health`. Both `/health` and `/ready` return static status responses: **they do not verify downstream dependencies or Bedrock availability**.

Endpoint sources: [API](../app/main.py), [Info](../services/info/app/main.py), [Advisor](../services/advisor/advisor_app/main.py), and [Advisor request/response schema](../services/advisor/advisor_app/models.py).

## CloudWatch logs and implemented alarms

Application log groups follow `/ecs/aws-container-platform-{environment}-{service}`, with stream prefix `app`. Retention is 7 days in DEV and 30 days in PROD. Start with the affected service and incident time window; correlate task IDs, deployment events, and application errors.

| Alarm suffix | Metric | Configured trigger |
| --- | --- | --- |
| `ecs-cpu-high` | `AWS/ECS` CPUUtilization | Average ≥80%, two 300-second periods |
| `ecs-memory-high` | `AWS/ECS` MemoryUtilization | Average ≥80%, two 300-second periods |
| `target-5xx` | `AWS/ApplicationELB` HTTPCode_Target_5XX_Count | Sum ≥5, one 300-second period |
| `unhealthy-hosts` | `AWS/ApplicationELB` UnHealthyHostCount | Maximum ≥1, two 60-second periods |
| Shared `alb-5xx` | `AWS/ApplicationELB` HTTPCode_ELB_5XX_Count | Sum ≥5, one 300-second period |

Service alarms use prefix `aws-container-platform-{environment}-{service}-`. The shared alarm is `aws-container-platform-{environment}-alb-5xx`. Distinguish application-generated target errors from ALB-generated errors during diagnosis.

All these alarms treat missing data as `notBreaching`. An OK alarm is not proof of availability when traffic or telemetry is absent. Alarm actions publish to SNS topic `aws-container-platform-{environment}-alarms`; email support is conditional and delivery is not verified. Recovery/OK notification actions are not configured.

Sources: [service alarms](../terraform/modules/observability/main.tf), [thresholds](../terraform/modules/observability/variables.tf), [shared alarm](../terraform/modules/platform-observability/main.tf), [shared threshold](../terraform/modules/platform-observability/variables.tf), [SNS](../terraform/modules/notifications/main.tf), and [task logging](../terraform/modules/ecs-services/main.tf).

## Diagnosing unhealthy ECS tasks or ALB targets

1. Establish scope: one service, all services, or frontend only. Record environment, source revision, intended image, failure time, and recent deployment events.
2. For tasks that cannot start, inspect ECS service events and stopped-task reasons before changing configuration. Check image/tag existence, execution-role permissions, endpoint availability/private DNS, and security groups. Image pulls depend on ECR API, ECR registry, and S3 connectivity; log delivery uses the Logs endpoint.
3. For tasks that exit or restart, inspect application logs and container exit reasons. Compare CPU/memory pressure with task sizing and scaling activity. Containers use a read-only root filesystem, so unexpected runtime writes can fail.
4. For unhealthy targets, inspect target-health reason codes, task registration, application port 8000, and ALB-to-task security-group rules. [ALB checks](../terraform/modules/alb-service-routing/main.tf) use HTTP `/health`, require 200, run every 30 seconds with a five-second timeout, and use two successes/failures as thresholds.
5. Compare with container health: [ECS checks](../terraform/modules/ecs-services/main.tf) also request `/health`, every 30 seconds with a five-second timeout, three retries, and a ten-second start period. The service has a 30-second load-balancer health grace period.
6. If targets are healthy but external requests fail, inspect the requested hostname, Route 53 alias, ACM certificate, HTTPS host rule, and ALB errors. Requests to the bare ALB hostname can hit its default 404 instead of a service rule.

Use [autoscaling configuration](../terraform/modules/ecs-autoscaling/main.tf) when investigating sustained CPU pressure. The policy scales on CPU only; a memory alarm does not directly trigger a memory scaling policy. There is no ECS Exec access configured for interactive container diagnosis.

## Advisor-service degraded behavior and Bedrock fallback

Advisor first creates a deterministic recommendation. With augmentation enabled, it calls Bedrock and validates the generated output. Inspect `augmentation.status`:

| Status | Operational meaning |
| --- | --- |
| `generated` | Augmentation succeeded for this request. |
| `fallback` | Augmentation failed; deterministic output remains available. Treat this as degraded behavior even with HTTP 200. |
| `disabled` | Augmentation is disabled by configuration. Confirm that this is intentional. |

For fallback, inspect Advisor logs for Bedrock error codes, request IDs, response-validation failures, and elapsed time. Check `BEDROCK_ENABLED`, `BEDROCK_MODEL_ID`, account/model access, Advisor task-role permissions, and the Runtime endpoint policy/connectivity. The client configures a two-second connect timeout, 30-second read timeout, and two maximum attempts. Success details are logged at INFO, but the application has no explicit logging configuration ensuring those messages are emitted.

The Runtime endpoint occupies one private subnet, so do not describe the entire Bedrock path as redundant across both AZs. No dedicated fallback alarm exists. Whether fallback requires an incident, and after what duration or rate, remains unresolved.

For frontend-only failures, check `config.js` and the API's `ALLOWED_ORIGINS`. Terraform uploads assets, but there is no automatic CloudFront invalidation; its configured default cache TTL is 3,600 seconds, so cached assets can lag an update.

Sources: [Bedrock implementation](../services/advisor/advisor_app/bedrock.py), [Advisor CORS](../services/advisor/advisor_app/main.py), [frontend infrastructure](../terraform/modules/static-frontend/main.tf), and environment composition linked above.

## Rollback procedure

ECS deployment circuit-breaker rollback is enabled in the [service module](../terraform/modules/ecs-services/main.tf). This is deployment-failure handling, not guaranteed recovery from application regressions or failed external smoke checks. Inspect ECS deployment events to establish whether rollback occurred and which revision is active.

**Proposed manual operator procedure — not yet validated end to end:**

1. Identify a previously published immutable image tag for the affected service and verify it still exists in the correct ECR repository. Establish why it is a suitable recovery version; the repository does not maintain a known-good release inventory.
2. Set that environment's corresponding image-tag input to the selected tag through the configuration change process. Preserve the complete enabled service set. Do not rebuild the old version or overwrite its tag.
3. Review Terraform Plan for the intended image change and any other resource changes. Apply through Terraform Apply only under the agreed authorization policy. Image rollback does not automatically reverse infrastructure or frontend changes.
4. Repeat all post-deployment verification, including target health, intended images, representative API requests, and Advisor augmentation status. Record the observed result; the repository does not automatically validate recovery after rollback.

Rollback authority, release selection, and recovery acceptance criteria remain unresolved.

## Environment teardown

Before teardown, confirm the exact environment and authorization, coordinate with other operators, and decide which logs or incident evidence must be retained. Environment log groups are destroyed with the environment. Resolve certificate DNS-validation ownership before treating DEV and PROD teardown as independent: both configurations request the same wildcard domain and manage validation records in the same hosted zone.

Dispatch [Terraform Destroy](../.github/workflows/terraform-destroy.yml) with the intended environment and confirmation exactly `DESTROY`. The workflow initializes and validates Terraform, creates `terraform plan -destroy -no-color -out=tfplan`, shows the plan, and executes `terraform apply -auto-approve tfplan`. It does not pause for approval between showing and applying the plan. Review scope separately before dispatch if required by the operating policy.

The workflow checks that the environment state is empty afterward. This does not prove that every related resource in the AWS account was removed. Shared ECR repositories are managed by the separate foundation and remain outside this workflow; the existing hosted zone and backend bucket are also outside the environment's managed resources. Frontend bucket deletion may fail if unmanaged objects remain because `force_destroy` is not configured. Investigate the failure rather than assuming cleanup completed.

Destroy can reduce ongoing environment costs, but retained resources may still incur charges. Existing cost controls are task capacity bounds, finite log retention, optional services/Bedrock, and explicit teardown. There are no budget alarms, ECR lifecycle policies, or scheduled shutdown procedures.

## Known operational limitations

- No dependency-aware readiness checks; `/health` and `/ready` cannot establish Bedrock health. HTTP success can conceal Advisor degradation.
- No CloudWatch dashboards, Container Insights, custom metrics, tracing, synthetic monitoring, ALB/CloudFront access logs, or VPC Flow Logs. No latency, task-count, certificate, or dedicated Bedrock-fallback alarms.
- No repository-defined deployment approvals or complete deployment serialization. State locking is not complete workflow coordination. Post-deployment checks sample one running task per service and compare image URI strings, not every task's digest.
- No automatically validated recovery after rollback, ECS Exec access, automated incident remediation, disaster recovery, or application-data backup procedures.
- No WAF, application authentication, request throttling/rate limiting, budget alarms, ECR lifecycle policies, scheduled shutdown, or automatic CloudFront invalidation.
- Services recommended by Advisor are recommendation content; the platform does not deploy those suggested databases, queues, or other architectures.

## Unresolved operational decisions

| Decision | What remains unresolved |
| --- | --- |
| Operator identities and approvals | Who may plan, deploy, roll back, or destroy; required review and coordination rules. |
| Notification ownership | SNS recipients, subscription confirmation/delivery testing, incident owner, and escalation path. |
| Rollback policy | Approved recovery versions, rollback authority, validation exercise, and acceptance criteria. |
| Teardown evidence retention | Which logs/evidence to preserve, where, for how long, and who owns retention. |
| Certificate DNS-validation ownership | Ownership of shared wildcard validation records across environment states and safe teardown/recreation behavior. |
| Advisor fallback | Whether degradation triggers an incident, applicable duration/rate thresholds, and acceptable disabled operation. |

Resolve these with the platform owner before relying on this document as a complete production operating policy.
