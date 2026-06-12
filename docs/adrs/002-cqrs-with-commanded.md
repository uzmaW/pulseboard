# ADR 002: CQRS with Commanded

## Status

Proposed

## Context

PulseBoard requires audit trails, event sourcing, and real-time projections for compliance and observability. We need a CQRS framework that integrates well with Elixir and Phoenix.

## Decision

Use Commanded for CQRS/Event Sourcing in `pulseboard_core`, with events flowing to projections for read models and to OpenTelemetry for observability.

## Consequences

### Positive

- Built-in event sourcing with audit trails
- Process managers for multi-step workflows
- Excellent Elixir ecosystem integration
- Projections for read-optimized views

### Negative

- Learning curve for Commanded patterns
- Event store infrastructure required (EventStore or PostgreSQL adapter)
- Increased complexity for simple CRUD operations

## Alternatives Considered

1. **Ash Framework** — Considered but Commanded offers more explicit CQRS control
2. **Plain Ecto** — Rejected for lack of event sourcing
3. **Custom implementation** — Rejected for reinventing the wheel
