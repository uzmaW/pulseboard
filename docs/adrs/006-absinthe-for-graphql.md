# ADR 006: Absinthe for GraphQL

## Status

Proposed

## Context

PulseBoard requires a GraphQL API for the frontend and external integrations. We need a mature Elixir GraphQL library.

## Decision

Use Absinthe for GraphQL API in `pulseboard_web`, with schema-first design and middleware for auth and RBAC.

## Consequences

### Positive

- Most mature Elixir GraphQL library
- Excellent Phoenix integration
- Support for subscriptions (real-time)
- Schema-first or code-first approaches
- Strong community and documentation

### Negative

- Schema maintenance overhead
- Learning curve for Absinthe-specific patterns
- Performance considerations for complex queries

## Alternatives Considered

1. **GraphQL Elixir** — Less mature
2. **REST only** — Rejected for frontend requirements
3. **gRPC only** — Rejected for client-facing API
