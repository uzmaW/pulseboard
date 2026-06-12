# Architecture

## Overview

PulseBoard is a multi-tenant, compliance-first real-time collaboration platform built with Elixir/Phoenix. It uses an umbrella app structure with domain-driven design, CQRS, and event sourcing.

## Design Principles

1. **Domain-Driven Design** — Separate aggregates, core logic from delivery and infrastructure
2. **CQRS + Event Sourcing** — Commands produce events, projections build read models
3. **Event-Driven** — Every action emits telemetry/events for audit, observability, and extensibility
4. **Compliance-First** — Audit, retention, consent, and export built into every model
5. **Plugin Architecture** — Extensible tenant workflows

## Umbrella Structure

```
pulseboard/
├── apps/
│   ├── pulseboard_web/           # LiveView UI + GraphQL API
│   ├── pulseboard_core/          # Domain logic: aggregates, policies, CQRS
│   ├── pulseboard_stream/        # WebRTC, video infra, recording, transcripts
│   ├── pulseboard_impersonation/ # Impersonation flow, RBAC, audit
│   ├── pulseboard_compliance/    # Regional compliance, audit, retention
│   ├── pulseboard_scheduler/     # Oban jobs, nudges, retention, onboarding
│   ├── pulseboard_plugins/       # Tenant workflows: Jira, Notion, Slack
│   └── pulseboard_infra/         # DB, Vault, secrets, gRPC clients
```

## Domain Models

### RealtimeSession

Reusable collaboration primitive for video calls, screen sharing, recording, and transcripts.

- **Fields**: id, participants, context, mode, recording_url, transcript
- **Contexts**: Task, Pulse, SupportTicket, OnboardingStep
- **Modes**: call, screenshare
- **Infrastructure**: LiveKit (WebRTC), S3/GCS (recordings), Whisper/AssemblyAI (transcripts)

### ImpersonationSession

Secure, auditable impersonation for support, QA, and training.

- **Fields**: id, admin_id, target_user_id, started_at, ended_at, reason
- **Security**: RBAC-controlled, audit trail, tenant-level consent toggle, scoped access

### Tenant

Multi-tenant organization with region-specific compliance.

- **Fields**: id, name, region, domain, admin_user_id, created_at
- **Onboarding**: Create tenant → provision RBAC → apply compliance → create Vault namespace → setup LiveKit → register telemetry

### RBAC

Role-based access control with granular permissions.

- **Models**: Role, Permission, Assignment
- **Enforcement**: GraphQL mutations, LiveView helpers, router plugs

### CompliancePolicy

Regional data governance and retention.

- **Fields**: tenant_id, region, retention_days, consent_required
- **Capabilities**: Audit hooks, consent flows, retention jobs, region-aware routing

## Infrastructure

### Secrets Management

- HashiCorp Vault with tenant-scoped namespaces
- Terraform for provisioning
- KV v2 engine for tenant secrets

### Observability

- OpenTelemetry for traces, metrics, logs
- ClickHouse for data storage
- Grafana for dashboards (tenant-specific overlays via Kustomize)

### Deployment

- GitHub Actions for CI/CD
- Terraform for infrastructure provisioning
- Kustomize for Kubernetes overlays
- ArgoCD for GitOps sync
- Docker Compose for local development

## Architecture Decision Records

ADRs are stored in `docs/adrs/` and track significant architectural decisions.

| ADR | Decision | Status |
|-----|----------|--------|
| 001 | Use Elixir umbrella app structure | Accepted |
| 002 | CQRS with Commanded | Proposed |
| 003 | LiveKit for WebRTC | Proposed |
| 004 | Vault for secrets management | Accepted |
| 005 | ArgoCD for GitOps | Accepted |
