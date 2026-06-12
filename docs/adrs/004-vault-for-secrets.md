# ADR 004: Vault for Secrets Management

## Status

Accepted

## Context

PulseBoard is a multi-tenant platform requiring secure, auditable secrets management with tenant isolation. Each tenant needs its own namespace for secrets.

## Decision

Use HashiCorp Vault with tenant-scoped namespaces, provisioned via Terraform. KV v2 engine for tenant secrets with per-tenant policies.

## Consequences

### Positive

- Industry-standard secrets management
- Built-in audit logging
- Tenant isolation via namespaces
- Terraform integration for infrastructure as code
- Support for dynamic secrets and rotation

### Negative

- Operational complexity
- Additional infrastructure to maintain
- Cost for Vault Enterprise features

## Alternatives Considered

1. **AWS Secrets Manager** — Vendor lock-in, less control
2. **SOPS + KMS** — Simpler but less feature-rich
3. **Environment variables** — Rejected for security reasons
