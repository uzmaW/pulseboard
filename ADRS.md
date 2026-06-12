# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) for PulseBoard.

## What is an ADR?

An ADR is a short document that captures a significant architectural decision along with its context and consequences.

## ADR Template

```markdown
# ADR [NUMBER]: [TITLE]

## Status

Proposed | Accepted | Deprecated | Superseded

## Context

What is the issue that we're seeing that motivates this decision?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or more difficult to do because of this change?

## Alternatives Considered

What other options were evaluated?
```

## List of ADRs

| ADR | Title | Status |
|-----|-------|--------|
| 001 | Use Elixir umbrella app structure | Accepted |
| 002 | CQRS with Commanded | Proposed |
| 003 | LiveKit for WebRTC | Proposed |
| 004 | Vault for secrets management | Accepted |
| 005 | ArgoCD for GitOps | Accepted |
| 006 | Absinthe for GraphQL | Proposed |
| 007 | Guardian for authentication | Proposed |
| 008 | Oban for background jobs | Accepted |
| 009 | ClickHouse for observability | Accepted |
| 010 | Kustomize for Kubernetes overlays | Accepted |
