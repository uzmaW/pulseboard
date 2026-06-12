# ADR 008: Oban for Background Jobs

## Status

Accepted

## Context

PulseBoard requires background job processing for tenant onboarding, compliance tasks, nudges, and retention policies.

## Decision

Use Oban for background job processing in `pulseboard_scheduler`, with PostgreSQL for job storage.

## Consequences

### Positive

- Built on PostgreSQL (no additional infrastructure)
- Excellent Elixir ecosystem integration
- Built-in dashboard for monitoring
- Support for crontab scheduling
- Oban Pro features for advanced use cases

### Negative

- PostgreSQL as job storage may limit throughput
- Learning curve for Oban patterns
- Job serialization overhead

## Alternatives Considered

1. **Broadway** — Stream processing, not general jobs
2. **Exq** — Redis dependency
3. **GenServer** — Not persistent, no scheduling
