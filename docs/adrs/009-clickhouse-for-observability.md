# ADR 009: ClickHouse for Observability

## Status

Accepted

## Context

PulseBoard requires high-performance observability data storage for traces, metrics, and logs with tenant-specific retention policies.

## Decision

Use ClickHouse as the observability data store, receiving data from OpenTelemetry collectors and serving Grafana dashboards.

## Consequences

### Positive

- Excellent columnar query performance
- Support for high-volume time-series data
- Compression for cost efficiency
- SQL interface for Grafana integration

### Negative

- Additional infrastructure component
- Operational complexity
- Separate from application database

## Alternatives Considered

1. **PostgreSQL** — Simpler but less performant for time-series
2. **InfluxDB** — Vendor concerns
3. **Prometheus** — Metrics only, not logs
