# ADR 010: Kustomize for Kubernetes Overlays

## Status

Accepted

## Context

PulseBoard requires per-tenant Kubernetes configuration for Grafana dashboards and infrastructure without duplicating base manifests.

## Decision

Use Kustomize overlays for tenant-specific configuration, with base manifests for shared resources.

## Consequences

### Positive

- No templating language to learn
- Git-friendly (plain YAML)
- Built into kubectl
- Clean separation of base and overlays

### Negative

- Limited logic compared to Helm
- Overlay complexity for deeply nested configs
- Learning curve for Kustomize patterns

## Alternatives Considered

1. **Helm** — More powerful but templating complexity
2. **Jsonnet** — Powerful but less accessible
3. **Manual YAML** — Rejected for duplication
