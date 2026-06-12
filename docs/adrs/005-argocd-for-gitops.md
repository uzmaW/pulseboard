# ADR 005: ArgoCD for GitOps

## Status

Accepted

## Context

PulseBoard requires automated deployment with tenant-specific Kubernetes overlays. We need a GitOps solution that integrates with Kustomize.

## Decision

Use ArgoCD for GitOps sync with Kustomize overlays for per-tenant Grafana dashboards and infrastructure configuration.

## Consequences

### Positive

- Declarative deployment from Git
- Automated sync with self-healing
- Kustomize integration for multi-tenant overlays
- UI for deployment visibility
- Multi-cluster support

### Negative

- Additional infrastructure component
- Learning curve for ArgoCD concepts
- Requires Kubernetes cluster

## Alternatives Considered

1. **FluxCD** — Lighter weight but less UI
2. **Jenkins X** — More opinionated, less flexible
3. **Manual kubectl** — Rejected for lack of automation
