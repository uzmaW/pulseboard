# ADR 001: Use Elixir Umbrella App Structure

## Status

Accepted

## Context

PulseBoard is a complex multi-tenant SaaS platform with multiple bounded contexts: real-time collaboration, impersonation, compliance, scheduling, and infrastructure. We need a modular structure that allows independent development and deployment of these concerns.

## Decision

Use Elixir's umbrella application structure with 8 sub-apps, each representing a bounded context:

- `pulseboard_web` — LiveView UI + GraphQL API
- `pulseboard_core` — Domain logic, aggregates, CQRS
- `pulseboard_stream` — WebRTC, recording, transcripts
- `pulseboard_impersonation` — Impersonation flow, RBAC, audit
- `pulseboard_compliance` — Regional policies, retention, consent
- `pulseboard_scheduler` — Oban jobs, nudges, onboarding
- `pulseboard_plugins` — Tenant workflows (Jira, Notion, Slack)
- `pulseboard_infra` — DB, Vault, secrets, gRPC clients

## Consequences

### Positive

- Clear separation of concerns
- Independent compilation and testing per app
- Enforced dependency boundaries
- Team autonomy per bounded context

### Negative

- Increased boilerplate
- Cross-app communication requires explicit interfaces
- More complex deployment configuration

## Alternatives Considered

1. **Monolith** — Rejected for lack of modularity at scale
2. **Polyglot microservices** — Rejected for operational complexity
3. **Elixir with domain contexts (no umbrella)** — Rejected for weaker boundary enforcement
