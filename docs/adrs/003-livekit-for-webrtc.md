# ADR 003: LiveKit for WebRTC

## Status

Proposed

## Context

PulseBoard requires real-time video collaboration (calls, screen sharing, recording) as a core primitive. We need a scalable, open-source WebRTC solution.

## Decision

Use LiveKit for WebRTC infrastructure in `pulseboard_stream`, with S3/GCS for recordings and Whisper/AssemblyAI for transcripts.

## Consequences

### Positive

- Open-source with commercial support available
- Built-in recording and egress features
- SFU architecture for scalability
- SDK support for Elixir, JavaScript, and mobile

### Negative

- Self-hosted infrastructure required
- Operational complexity for scaling
- Vendor dependency for managed features

## Alternatives Considered

1. **mediasoup** — Lower-level, more control but more work
2. **Twilio** — Managed but expensive at scale
3. **Agora** — Vendor lock-in concerns
