# PulseBoard

A production-grade, multi-tenant, compliance-first real-time collaboration platform built with Elixir/Phoenix.

## Features

- **Real-time Collaboration** — WebRTC video calls, screen sharing, recording, and transcripts via LiveKit
- **User Impersonation** — Secure, auditable impersonation for support, QA, and training
- **Multi-Tenancy** — Domain-based tenant isolation with per-tenant Vault namespaces
- **RBAC** — Role-based access control with GraphQL and LiveView enforcement
- **Compliance** — Regional data governance, audit trails, consent flows, retention policies
- **Observability** — OpenTelemetry, ClickHouse, and Grafana dashboards
- **GitOps** — Terraform, Kustomize, and ArgoCD for infrastructure and deployment
- **Plugin Architecture** — Extensible tenant workflows (Jira, Notion, Slack)

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Elixir 1.15+ / OTP 26+ |
| Framework | Phoenix (LiveView, Absinthe GraphQL) |
| Database | PostgreSQL |
| Real-time | LiveKit (WebRTC) |
| Secrets | HashiCorp Vault |
| Background Jobs | Oban |
| CQRS/Events | Commanded or Ash Framework |
| Observability | OpenTelemetry + ClickHouse + Grafana |
| Infrastructure | Terraform + Kustomize + ArgoCD |
| CI/CD | GitHub Actions |

## Quick Start

### Prerequisites

- Elixir 1.15+ / OTP 26+
- PostgreSQL 15+
- Docker & Docker Compose
- Terraform (for Vault setup)

### Setup

```bash
# Clone the repository
git clone https://github.com/your-org/pulseboard.git
cd pulseboard

# Install dependencies
mix deps.get

# Setup the database
mix ecto.setup

# Start local services (PostgreSQL, Vault, ClickHouse)
docker compose up -d

# Seed tenant data
mix run priv/repo/seeds.exs

# Start the development server
mix phx.server
```

Visit [http://localhost:4000](http://localhost:4000).

### Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

## Project Structure

```
pulseboard/
├── apps/
│   ├── pulseboard_web/           # LiveView UI + GraphQL API
│   ├── pulseboard_core/          # Domain logic: aggregates, policies, CQRS
│   ├── pulseboard_stream/        # WebRTC, video infra, recording, transcripts
│   ├── pulseboard_impersonation/ # Impersonation flow, RBAC, audit
│   ├── pulseboard_compliance/    # Regional compliance, audit, retention
│   ├── pulseboard_scheduler/     # Oban jobs, nudges, retention, onboarding
│   ├── pulseboard_plugins/       # Tenant workflows: Jira, Notion, Slack
│   └── pulseboard_infra/         # DB, Vault, secrets, gRPC clients
├── config/
├── infra/                        # Terraform, Vault, Kustomize
├── .github/                      # CI/CD workflows
├── docker-compose.yml
├── ARCHITECTURE.md
├── CONTRIBUTING.md
└── CHANGELOG.md
```

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed design decisions, domain models, and infrastructure patterns.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development workflow, coding standards, and PR guidelines.

## License

MIT License. See [LICENSE](LICENSE) for details.
