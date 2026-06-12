# ADR 007: Guardian for Authentication

## Status

Proposed

## Context

PulseBoard requires JWT-based authentication with support for impersonation claims and multi-tenant scoping.

## Decision

Use Guardian for authentication with custom claims for impersonation scope and tenant ID.

## Consequences

### Positive

- Mature Elixir authentication library
- JWT support with custom claims
- Plug-based architecture for flexibility
- Support for token refresh and revocation

### Negative

- JWT complexity for session management
- Custom claims require careful design
- Token size considerations

## Alternatives Considered

1. **Pow** — Simpler but less customizable
2. **Auth0** — Vendor lock-in
3. **Custom implementation** — Rejected for reinventing the wheel
