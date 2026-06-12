# PulseBoard: A Deep Dive into Architecture, Language, and Framework

## The Definitive Technical Guide

---

## Table of Contents

1. **Introduction** — What PulseBoard Is and Why It Exists
2. **Language & Runtime** — Elixir, Erlang/OTP, and the BEAM VM
3. **Framework Layer** — Phoenix, LiveView, Absinthe, and OTP Applications
4. **Umbrella Architecture** — Domain-Driven Design in Practice
5. **Domain Models** — The Core Business Logic
6. **Compliance Engine** — Regional Data Governance, Audit Trails, Consent, and Retention
7. **Observability** — Telemetry, ClickHouse, and the Path to OpenTelemetry
8. **GitOps** — Terraform, Kustomize, and ArgoCD for Deployment
9. **Plugin Architecture** — Extensible Tenant Workflows
10. **Infrastructure** — Vault, LiveKit, and Secrets Management
11. **Frontend** — LiveView, Tailwind CSS, and Corporate-Grade UX
12. **Testing Strategy** — From Unit to Integration
13. **Deployment** — From Docker Compose to Kubernetes
14. **Appendix** — Architecture Decision Records Summary

---

## Chapter 1: Introduction

### What PulseBoard Is

PulseBoard is a **multi-tenant, compliance-first, real-time collaboration platform**. It enables organizations to conduct secure video sessions, screen shares, and collaborative workflows while maintaining strict regional data governance.

Think of it as the intersection of Zoom, Jira, and a compliance officer's dream — all built on a runtime that guarantees fault tolerance and massive concurrency.

### The Problem It Solves

Most SaaS platforms bolt on compliance and multi-tenancy after the fact. PulseBoard treats them as first-class architectural concerns:

- **EU tenants** get 90-day retention and mandatory consent flows
- **US tenants** get 365-day retention with optional audit
- **APAC tenants** get 180-day retention with consent requirements
- **Every action** is auditable, every session is traceable, every secret is vaulted

### Design Principles

| Principle | Implementation |
|-----------|---------------|
| Domain-Driven Design | Separate aggregates per OTP app |
| CQRS + Event Sourcing | Commands produce events; projections build read models |
| Event-Driven | Every action emits telemetry/events |
| Compliance-First | Audit, retention, consent built into every model |
| Plugin Architecture | Extensible tenant workflows (Jira, Notion, Slack) |
| Infrastructure as Code | Terraform, Kustomize, ArgoCD |

---

## Chapter 2: Language & Runtime

### Elixir: The Language

PulseBoard is written in **Elixir**, a dynamic, functional language that compiles to Erlang bytecode and runs on the BEAM virtual machine.

```elixir
# Elixir syntax — pattern matching, pipes, and immutability
def region_defaults("EU"),
  do: %{retention_days: 90, consent_required: true, audit_enabled: true}

def region_defaults("US"),
  do: %{retention_days: 365, consent_required: false, audit_enabled: true}
```

**Why Elixir?**

- **Functional purity** — No mutable state, no side effects hidden in functions
- **Pattern matching** — Destructure data declaratively; the compiler enforces exhaustiveness
- **Pipe operator** — Compose transformations as readable pipelines
- **Macro system** — Metaprogramming for DSLs (Phoenix schemas, Ecto queries)
- **Type specs** — Optional but enforced with `dialyzer` for gradual typing

### Erlang/OTP: The Runtime

Beneath Elixir sits **Erlang/OTP** — the battle-tested runtime that powers WhatsApp, Discord, and the Swedish telephone network (running since 1998 without restart).

**Key OTP Concepts Used in PulseBoard:**

| Concept | PulseBoard Usage |
|---------|-----------------|
| **Supervision Trees** | Each OTP app has a supervisor restarting crashed processes |
| **GenServer** | Stateful processes for session management, plugin state |
| **GenEvent / :telemetry** | Event bus for observability metrics |
| **Application** | Each umbrella app is a started/stopped OTP application |
| **Task.Supervisor** | Async tasks for retention cleanup, onboarding |

### The BEAM VM: Why It Matters

The BEAM (Bogdan/Björn's Erlang Abstract Machine) provides:

- **Per-process isolation** — A crash in the ClickHouse sink cannot bring down the web server
- **Hot code loading** — Update code in production without stopping the system
- **Scheduler preemptiveness** — Each process gets fair CPU time; no single process can starve others
- **Distribution** — Nodes can connect, forming clusters for horizontal scaling
- **Lightweight processes** — Creating 100,000 processes costs less memory than 100 OS threads

```
┌─────────────────────────────────────────────┐
│                  BEAM VM                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐    │
│  │ Process  │ │ Process  │ │ Process  │    │
│  │ (web)    │ │ (stream) │ │ (compl.) │    │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘    │
│       │            │            │            │
│  ┌────┴────────────┴────────────┴────┐      │
│  │         Scheduler (1 per core)    │      │
│  └───────────────────────────────────┘      │
│  ┌───────────────────────────────────┐      │
│  │         GC (per-process)          │      │
│  └───────────────────────────────────┘      │
└─────────────────────────────────────────────┘
```

---

## Chapter 3: Framework Layer

### Phoenix: The Web Framework

PulseBoard uses **Phoenix 1.7+**, the most mature Elixir web framework.

**Phoenix Components Used:**

| Component | Purpose |
|-----------|---------|
| `Phoenix.Router` | HTTP routing with pipelines |
| `Phoenix.Endpoint` | HTTP/WS entry point |
| `Phoenix.LiveView` | Server-rendered, real-time UI without JavaScript |
| `Phoenix.PubSub` | Real-time event distribution |
| `Phoenix.Component` | Declarative UI functions (HEEx templates) |

### LiveView: The UI Paradigm

Instead of a separate React/Vue SPA, PulseBoard uses **Phoenix LiveView** — server-rendered UI that updates in real-time over WebSocket.

```
User clicks "Start Session"
        │
        ▼
┌──────────────────┐
│  LiveView Process │  ← Server-side, in the BEAM
│  (one per user)   │
│                   │
│  handle_event()   │  ← Processes the click
│  assign()         │  ← Updates state
│  render()         │  ← Returns new HTML diff
└────────┬─────────┘
         │
         ▼ (WebSocket diff)
┌──────────────────┐
│  Browser          │  ← Only the changed DOM nodes update
│  (minimal JS)     │
└──────────────────┘
```

**Why LiveView over a SPA?**
- Zero client-side JavaScript for business logic
- Real-time updates without API design decisions
- Server-side state eliminates serialization concerns
- Unified codebase (no separate frontend/backend repos)

### Absinthe: GraphQL API

For programmatic access, PulseBoard exposes a **GraphQL API via Absinthe**:

```elixir
# Schema definition
object :session do
  field :id, non_null(:string)
  field :participants, list_of(:participant)
  field :status, non_null(:string)
end

# Resolver
def resolve_sessions(_, _args, %{context: %{current_user: user}}) do
  {:ok, Sessions.list_for_user(user)}
end
```

### OTP Application Structure

Each umbrella app is a proper OTP application with its own supervision tree:

```elixir
# pulseboard_compliance/application.ex
defmodule PulseboardCompliance.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Compliance workers would go here
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end
end
```

---

## Chapter 4: Umbrella Architecture

### The Umbrella Pattern

Elixir's umbrella project lets PulseBoard organize 8 separate OTP applications under one roof:

```
pulseboard/
├── apps/
│   ├── pulseboard_core/          # Domain logic (THE HEART)
│   ├── pulseboard_web/           # LiveView UI + GraphQL
│   ├── pulseboard_stream/        # WebRTC / LiveKit
│   ├── pulseboard_impersonation/ # Impersonation flows
│   ├── pulseboard_compliance/    # Regional compliance
│   ├── pulseboard_scheduler/     # Background jobs
│   ├── pulseboard_plugins/       # Jira, Notion, Slack
│   └── pulseboard_infra/         # DB, Vault, ClickHouse
├── config/                       # Shared configuration
├── docs/                         # ADRs, architecture docs
└── mix.exs                       # Umbrella root
```

**Why Umbrella Over Monolith?**

| Concern | Monolith | Umbrella |
|---------|----------|----------|
| Compilation | All or nothing | Per-app (`mix compile` in one app) |
| Dependencies | Everything coupled | Explicit cross-app deps |
| Testing | Slow full suite | Run per-app tests |
| Deployment | Single unit | Could split later |
| Team ownership | Shared codebase | Clear ownership boundaries |

### Cross-App Dependencies

```
pulseboard_web ──depends on──► pulseboard_core
     │                              │
     ├──► pulseboard_stream         │
     ├──► pulseboard_impersonation  │
     └──► pulseboard_compliance ◄───┘
                 │
                 └──► pulseboard_core

pulseboard_plugins ──► (standalone, duck-typed)
pulseboard_scheduler ──► pulseboard_core
pulseboard_infra ──► (standalone, provides Repo/Vault)
```

### Dependency Rules

- **`pulseboard_core`** depends on NOTHING — it is the innermost circle
- **`pulseboard_infra`** depends on `pulseboard_core` for types only
- **`pulseboard_web`** depends on all domain apps
- **`pulseboard_plugins`** is intentionally decoupled (duck-typed dispatch)

---

## Chapter 5: Domain Models

### The Aggregate Pattern (DDD)

PulseBoard follows Domain-Driven Design with **aggregates** — clusters of entities and value objects treated as a single unit for data changes.

```elixir
# CompliancePolicy — an aggregate root
defmodule PulseboardCore.Compliance.CompliancePolicy do
  @enforce_keys [:id, :tenant_id, :region]
  defstruct [:id, :tenant_id, :region, :retention_days,
             :consent_required, :audit_enabled, :data_classification,
             :created_at, :updated_at]

  @type t :: %__MODULE__{
    id: binary(),
    tenant_id: binary(),
    region: binary(),
    retention_days: non_neg_integer(),
    consent_required: boolean(),
    audit_enabled: boolean(),
    data_classification: :public | :internal | :confidential | :restricted,
    created_at: DateTime.t(),
    updated_at: DateTime.t()
  }
end
```

### Key Domain Models

**RealtimeSession** — The collaboration primitive
```elixir
%RealtimeSession{
  id: "session-abc",
  tenant_id: "tenant-1",
  participants: [%{user_id: "user-1", role: "host"}],
  context: :support,      # :task | :pulse | :support_ticket | :onboarding_step
  mode: :call,            # :call | :screenshare
  recording_url: nil,
  transcript: nil
}
```

**Tenant** — Multi-tenant organization
```elixir
%Tenant{
  id: "tenant-1",
  name: "Acme Corp",
  region: "EU",
  domain: "acme.pulseboard.dev",
  admin_user_id: "user-admin-1"
}
```

**RBAC** — Role-Based Access Control
```elixir
# Roles, Permissions, Assignments
role: :admin | :member | :viewer
permission: :create_session | :impersonate_user | :manage_compliance
```

**ImpersonationSession** — Secure impersonation
```elixir
%ImpersonationSession{
  id: "imp-123",
  admin_id: "admin-1",
  target_user_id: "user-1",
  reason: "Support ticket #456",
  scope: :support,        # :support | :qa | :training | :debugging
  started_at: ~U[2026-06-13 10:00:00Z],
  ended_at: nil
}
```

### Event Sourcing Pattern

Every state change produces an event:

```elixir
# Event creation
PulseboardCore.Event.new(
  :session_started,           # event type
  "tenant-1",                 # tenant_id
  "user-1",                   # user_id
  %{session_id: "s-123"}      # payload
)

# Event bus publish
|> PulseboardCore.Event.Bus.publish()
```

Events flow to:
- **Telemetry** — Metrics and dashboards
- **ClickHouse** — Persistent event store
- **Audit log** — Compliance trail
- **Plugins** — Trigger workflows

---

## Chapter 6: Compliance Engine

### Architecture

The compliance engine is split across two apps:

```
pulseboard_core/              pulseboard_compliance/
┌─────────────────────┐       ┌─────────────────────┐
│ CompliancePolicy    │       │ PulseboardCompliance │
│ (aggregate root)    │◄──────│ (context/facade)     │
│                     │       │                      │
│ - new/1             │       │ - apply_policy/1     │
│ - retention_exceeded?/2│    │ - retention_exceeded?/2│
│ - consent_required?/1 │    │ - region_defaults/1   │
│ - region_defaults/1  │      │ - log_audit/4        │
└─────────────────────┘       └─────────────────────┘
```

### Region-Specific Defaults

This is where compliance becomes a first-class concern:

```elixir
def region_defaults("EU"), do:
  %{retention_days: 90, consent_required: true, audit_enabled: true}

def region_defaults("US"), do:
  %{retention_days: 365, consent_required: false, audit_enabled: true}

def region_defaults("APAC"), do:
  %{retention_days: 180, consent_required: true, audit_enabled: true}

def region_defaults(_), do:
  %{retention_days: 365, consent_required: false, audit_enabled: true}
```

**What this means in practice:**

| Region | Data Retention | Consent Required | Audit Enabled |
|--------|---------------|-----------------|---------------|
| EU | 90 days | Yes (GDPR) | Yes |
| US | 365 days | No | Yes |
| APAC | 180 days | Yes | Yes |
| Global | 365 days | No | Yes |

### Audit Trail System

Every compliance-relevant action goes through `log_audit/4`:

```elixir
PulseboardCompliance.log_audit(
  "tenant-1",          # tenant_id
  "user-1",            # user_id
  :session_started,    # action (atom)
  %{session_id: "s-1"} # details
)
```

This does two things:
1. Emits a **telemetry event** `[:pulseboard, :compliance, :audit_logged]`
2. Publishes an **event on the Event Bus** for downstream consumers

### Retention Policy Engine

```elixir
# Check if data has exceeded retention period
PulseboardCompliance.retention_exceeded?(tenant_id, data_timestamp)

# Internally:
def retention_exceeded?(%__MODULE__{retention_days: days}, data_timestamp) do
  cutoff = DateTime.add(DateTime.utc_now(), -days, :day)
  DateTime.compare(data_timestamp, cutoff) == :lt
end
```

### Data Classification

Four levels of sensitivity:

```elixir
@type data_classification ::
  :public        # No restrictions
  | :internal    # Internal use only
  | :confidential # PII, requires encryption
  | :restricted   # Highly sensitive, strictest controls
```

### Production Roadmap

The compliance engine currently has **domain logic fully realized** but needs:

- [ ] Ecto schemas for persisting compliance policies
- [ ] Consent flow UI (collect, store, validate consent)
- [ ] Audit trail storage (write to ClickHouse)
- [ ] GDPR data export (right to data portability)
- [ ] GDPR data deletion (right to be forgotten)
- [ ] Scheduled retention cleanup jobs (via Oban)

---

## Chapter 7: Observability

### The Three Pillars

PulseBoard's observability strategy follows the three pillars model:

```
┌─────────────────────────────────────────────────────┐
│                  OBSERVABILITY                       │
│                                                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐  │
│  │   Metrics    │ │   Traces    │ │    Logs     │  │
│  │              │ │             │ │             │  │
│  │  :telemetry  │ │  (planned)  │ │  (planned)  │  │
│  │  + ClickHouse│ │  OpenTel.   │ │  Structured │  │
│  └─────────────┘ └─────────────┘ └─────────────┘  │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │              Dashboards                      │   │
│  │          Grafana (planned)                   │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### Telemetry: The Foundation

PulseBoard uses Erlang's **`:telemetry`** library pervasively. Every app emits events:

```elixir
# Compliance events
[:pulseboard, :compliance, :policy_applied]
[:pulseboard, :compliance, :audit_logged]

# Session events
[:pulseboard, :session, :started]
[:pulseboard, :session, :ended]

# Stream events
[:pulseboard, :stream, :room_created]

# Impersonation events
[:pulseboard, :impersonation, :started]

# Event bus events
[:pulseboard, :event, :published]

# Scheduler events
[:pulseboard, :nudge, :sent]
[:pulseboard, :onboarding, :scheduled]
[:pulseboard, :retention, :cleanup_scheduled]
```

**Telemetry in the Web Layer:**

```elixir
# pulseboard_web/telemetry.ex
def metrics do
  [
    # Phoenix endpoint metrics
    summary("phoenix.endpoint.start.system_time", unit: {:native, :millisecond}),
    summary("phoenix.endpoint.stop.duration", unit: {:native, :millisecond}),

    # Ecto metrics
    summary("pulseboard.repo.query.total_time", unit: {:native, :millisecond}),
    summary("pulseboard.repo.query.decode_time", unit: {:native, :millisecond}),

    # PulseBoard custom metrics
    summary("pulseboard.session.started"),
    summary("pulseboard.impersonation.started"),
    counter("pulseboard.event.published")
  ]
end
```

### ClickHouse: The Event Store

PulseBoard uses **ClickHouse** for high-throughput event storage:

```elixir
# clickhouse/sink.ex
def push_event(event) do
  query = """
  INSERT INTO pulseboard_events (id, type, tenant_id, user_id, payload, timestamp)
  VALUES ('#{event.id}', '#{event.type}', '#{event.tenant_id}', ...)
  """

  HTTPoison.post("#{url}/", query, [{"Content-Type", "text/plain"}])
end
```

**Table Schema (intended):**

```sql
CREATE TABLE pulseboard_events (
  id String,
  type LowCardinality(String),
  tenant_id String,
  user_id String,
  payload String,        -- JSON-encoded
  timestamp DateTime
) ENGINE = MergeTree()
ORDER BY (tenant_id, type, timestamp);
```

**Why ClickHouse?**

| Feature | ClickHouse | PostgreSQL |
|---------|-----------|------------|
| Write throughput | 1M+ rows/sec | 10K-50K rows/sec |
| Columnar storage | Yes (compressed) | No (row-based) |
| Analytical queries | Sub-second | Minutes |
| Time-series data | Native support | Requires indexing |
| Cost at scale | 10x cheaper | Expensive |

### OpenTelemetry (Planned)

The ADRs specify OpenTelemetry as the distributed tracing standard, but this is **not yet implemented**. The current state:

- ADR 009 documents the decision to use OpenTelemetry
- Only bare `:telemetry` library is used (Erlang's built-in)
- No `opentelemetry`, `opentelemetry_exporter`, or `opentelemetry_telemetry` hex packages

**What's needed:**

```elixir
# mix.exs additions needed
{:opentelemetry, "~> 1.3"},
{:opentelemetry_exporter, "~> 1.6"},
{:opentelemetry_telemetry, "~> 1.1"},
{:opentelemetry_phoenix, "~> 1.1"}
```

### Grafana Dashboards (Planned)

ADR 010 documents per-tenant Grafana dashboards via Kustomize overlays:

```
k8s/
├── base/
│   ├── grafana/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   └── kustomization.yaml
└── overlays/
    ├── tenant-eu/
    │   ├── grafana-dashboard.json    # EU-specific dashboards
    │   └── kustomization.yaml
    └── tenant-us/
        ├── grafana-dashboard.json    # US-specific dashboards
        └── kustomization.yaml
```

### docker-compose.yml

```yaml
services:
  postgres:15       # Primary database
  vault:1.15        # Secrets management
  clickhouse:23.8   # Observability storage (ports 8123, 9000)
  livekit:latest    # WebRTC server
```

**Not yet included:** Grafana, Prometheus, OpenTelemetry Collector, Jaeger

---

## Chapter 8: GitOps

### The Deployment Pipeline

PulseBoard's deployment strategy uses three infrastructure-as-code tools:

```
┌──────────┐    ┌──────────┐    ┌──────────┐
│ Terraform │───►│ Kustomize│───►│  ArgoCD  │───► Kubernetes
│           │    │          │    │          │
│ Provision │    │ Overlay  │    │ GitOps   │
│ infra     │    │ configs  │    │ sync     │
└──────────┘    └──────────┘    └──────────┘
```

### Terraform: Infrastructure Provisioning

**Status:** ADR accepted, .gitignore pre-configured, **no .tf files yet**

```hcl
# Planned: infra/main.tf
resource "aws_eks_cluster" "pulseboard" {
  name     = "pulseboard-${var.environment}"
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "aws_rds_cluster" "postgres" {
  cluster_identifier = "pulseboard-${var.environment}"
  engine             = "aurora-postgresql"
  engine_version     = "15.4"
}
```

**What Terraform will manage:**
- EKS/Kubernetes cluster
- RDS PostgreSQL instances
- ClickHouse cluster
- Vault deployment
- IAM roles and policies
- VPC/networking

### Kustomize: Kubernetes Overlays

**Status:** ADR accepted, **no kustomization.yaml files yet**

The Kustomize strategy enables per-tenant configuration without templating:

```yaml
# k8s/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
  - configmap.yaml
  - ingress.yaml
```

```yaml
# k8s/overlays/tenant-eu/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
patchesStrategicMerge:
  - grafana-dashboard.yaml
  - retention-config.yaml
  - compliance-config.yaml
```

**Why Kustomize over Helm?**
- No templating language — just plain YAML patches
- Git-friendly diffs
- Built into `kubectl`
- Simpler mental model

### ArgoCD: GitOps Sync

**Status:** ADR accepted, **no Application CRDs yet**

```yaml
# argocd/application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: pulseboard
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/pulseboard/pulseboard.git
    targetRevision: HEAD
    path: k8s/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: pulseboard
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

**ArgoCD Benefits:**
- Declarative deployment from Git
- Automated sync with self-healing
- UI for deployment visibility
- Multi-cluster support

---

## Chapter 9: Plugin Architecture

### The Plugin Contract

PulseBoard's plugin system uses **duck-typed dispatch** — any module that implements `init/1` and `execute/2` is a valid plugin:

```elixir
# Plugin registry
defmodule PulseboardPlugins do
  @type plugin :: module()
  @type config :: map()

  def available do
    [PulseboardPlugins.Jira, PulseboardPlugins.Notion, PulseboardPlugins.Slack]
  end

  def init(plugin, config) do
    if function_exported?(plugin, :init, 1) do
      plugin.init(config)
    else
      {:ok, plugin}
    end
  end

  def execute(plugin, action, params) do
    plugin.execute(action, params)
  rescue
    UndefinedFunctionError -> {:error, :not_implemented}
  end
end
```

### Jira Plugin

```elixir
defmodule PulseboardPlugins.Jira do
  def init(config) do
    required = [:base_url, :api_token, :project_key]
    missing = Enum.filter(required, fn key ->
      not Map.has_key?(config, key) or is_nil(config[key])
    end)

    if Enum.empty?(missing), do: {:ok, __MODULE__},
       else: {:error, {:missing_config, missing}}
  end

  def execute(:create_issue, params) do
    {:ok, %{issue_key: "PROJ-#{unique_int()}", url: params[:url]}}
  end

  def execute(:update_issue, params) do
    {:ok, %{updated: true, issue_key: params[:issue_key]}}
  end

  def execute(:get_issue, params) do
    {:ok, %{issue_key: params[:issue_key], status: "open"}}
  end
end
```

### Notion Plugin

```elixir
defmodule PulseboardPlugins.Notion do
  def init(config) do
    required = [:api_key, :workspace_id]
    # ... validation
  end

  def execute(:create_page, params) do
    {:ok, %{page_id: generate_id(), title: params[:title]}}
  end

  def execute(:query_database, _params) do
    {:ok, %{results: [], has_more: false}}
  end
end
```

### Slack Plugin

```elixir
defmodule PulseboardPlugins.Slack do
  def init(config) do
    required = [:bot_token, :signing_secret]
    # ... validation
  end

  def execute(:send_message, params) do
    {:ok, %{sent: true, channel: params[:channel], ts: System.system_time(:second)}}
  end

  def execute(:send_dm, params) do
    {:ok, %{sent: true, user: params[:user_id]}}
  end
end
```

### Plugin Integration Points

Plugins are triggered via the Event Bus:

```
User starts session ──► Event :session_started ──► Plugin dispatcher
                                                      │
                    ┌─────────────────────────────────┤
                    │                                 │
                    ▼                                 ▼
              Jira: create_issue            Slack: send_message
              "Session started"             "#support: Session started"
```

### Current Limitations

| Feature | Status |
|---------|--------|
| Plugin contract (init/execute) | Defined |
| Config validation | Implemented |
| Jira/Notion/Slack stubs | Implemented |
| Real HTTP API calls | Not implemented |
| OAuth/token refresh | Not implemented |
| Dynamic plugin discovery | Not implemented |
| Plugin persistence | Not implemented |
| Event-driven triggers | Not implemented |

---

## Chapter 10: Infrastructure

### HashiCorp Vault

Full CRUD operations for secrets management:

```elixir
defmodule PulseboardInfra.Vault do
  def create_namespace(namespace) do
    # POST /v1/sys/namespaces/:namespace
  end

  def write_secret(path, data) do
    # POST /v1/:path
  end

  def read_secret(path) do
    # GET /v1/:path
  end

  def delete_secret(path) do
    # DELETE /v1/:path
  end

  def list_secrets(path) do
    # GET /v1/:path?list=true
  end
end
```

**Tenant-scoped secrets:**

```
pulseboard/
├── tenants/
│   ├── tenant-eu/
│   │   ├── database/creds
│   │   ├── jira/api_token
│   │   └── slack/bot_token
│   └── tenant-us/
│       ├── database/creds
│       └── jira/api_token
```

### LiveKit (WebRTC)

```elixir
defmodule PulseboardStream do
  def create_room(name, opts \\ []) do
    # POST to LiveKit API
  end

  def generate_token(room, participant) do
    # JWT token generation
  end

  def delete_room(room) do
    # DELETE from LiveKit API
  end
end
```

---

## Chapter 11: Frontend

### Tailwind CSS

PulseBoard uses **Tailwind CSS 3.4** with a custom corporate design system:

```css
/* app.css — Custom properties for theming */
:root {
  --color-primary-50: #eff6ff;
  --color-primary-600: #2563eb;
  --color-primary-700: #1d4ed8;
}

.dark {
  --color-primary-50: #1e3a5f;
  --color-primary-600: #3b82f6;
}
```

### Component Library

**Card component:**
```heex
<div class="card">
  <div class="card-header">Title</div>
  <div class="card-body">Content</div>
</div>
```

**Empty state:**
```heex
<div class="empty-state">
  <svg class="empty-state-icon">...</svg>
  <h3 class="empty-state-title">No sessions yet</h3>
  <p class="empty-state-description">Create one to get started.</p>
</div>
```

**Skeleton loading:**
```heex
<div class="skeleton skeleton-text"></div>
<div class="skeleton skeleton-text w-3/4"></div>
<div class="skeleton skeleton-card"></div>
```

### Dark Mode

Toggle persisted in localStorage:

```javascript
// app.js
Hooks.DarkMode = {
  mounted() {
    this.el.addEventListener("click", () => {
      const isDark = document.documentElement.classList.contains("dark")
      localStorage.setItem("darkMode", isDark ? "light" : "dark")
      this.applyTheme()
    })
  },
  applyTheme() {
    const saved = localStorage.getItem("darkMode")
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
    if (saved === "dark" || (saved === null && prefersDark)) {
      document.documentElement.classList.add("dark")
    } else {
      document.documentElement.classList.remove("dark")
    }
  }
}
```

### Accessibility

- Skip-link for keyboard navigation
- `aria-label` on all navigation
- `aria-current="page"` on active nav links
- `aria-required`, `aria-invalid`, `aria-describedby` on forms
- `role="alert"` on validation errors
- `role="dialog"`, `aria-modal="true"` on confirmation dialogs
- Focus management on route change
- Reduced-motion media query

---

## Chapter 12: Testing Strategy

### Test Structure

```
apps/
├── pulseboard_core/test/
│   ├── pulseboard_core/tenant_test.exs
│   ├── pulseboard_core/realtime_session_test.exs
│   ├── pulseboard_core/compliance/compliance_policy_test.exs
│   └── ...
├── pulseboard_stream/test/
├── pulseboard_web/test/
│   └── pulseboard_web_test.exs
└── ...
```

### Test Types

| Type | Framework | Coverage |
|------|-----------|----------|
| Unit | ExUnit | Domain models, aggregates, policies |
| Integration | ExUnit | Context modules, cross-app workflows |
| LiveView | Phoenix.LiveViewTest | UI interactions, form submissions |
| Contract | ExUnit | Plugin init/execute contracts |

### Running Tests

```bash
# All apps
mix test

# Specific app
cd apps/pulseboard_core && mix test

# With coverage
mix test --cover

# With warnings-as-errors (CI)
mix compile --warnings-as-errors
```

### Test Results

```
pulseboard_core:           42 tests, 0 failures
pulseboard_scheduler:       3 tests, 0 failures
pulseboard_compliance:      3 tests, 0 failures
pulseboard_impersonation:   3 tests, 0 failures
pulseboard_web:             1 test, 0 failures
pulseboard_plugins:         3 tests, 0 failures
─────────────────────────────────────────────
Total:                     55 tests, 0 failures
```

---

## Chapter 13: Deployment

### Local Development

```bash
# Start all services
docker-compose up -d

# Run the app
mix phx.server
```

### Staging / Production

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Developer  │────►│    GitHub    │────►│   ArgoCD    │
│   pushes     │     │    Actions   │     │   syncs     │
│   code       │     │   CI/CD      │     │   to K8s    │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │ Kubernetes   │
                                        │ Cluster      │
                                        │              │
                                        │ - Web pods   │
                                        │ - Stream pods│
                                        │ - DB (RDS)   │
                                        │ - Vault      │
                                        │ - ClickHouse │
                                        │ - LiveKit    │
                                        │ - Grafana    │
                                        └─────────────┘
```

---

## Chapter 14: Architecture Decision Records

| ADR | Decision | Status | Impact |
|-----|----------|--------|--------|
| 001 | Elixir umbrella app structure | Accepted | Project structure |
| 002 | CQRS with Commanded | Proposed | Command/event separation |
| 003 | LiveKit for WebRTC | Proposed | Video infrastructure |
| 004 | Vault for secrets management | Accepted | Security posture |
| 005 | ArgoCD for GitOps | Accepted | Deployment strategy |
| 006 | PostgreSQL for primary storage | Accepted | Data layer |
| 007 | Absinthe for GraphQL | Accepted | API layer |
| 008 | Phoenix LiveView for UI | Accepted | Frontend architecture |
| 009 | ClickHouse for observability | Accepted | Metrics/traces storage |
| 010 | Kustomize for overlays | Accepted | Per-tenant config |

---

## Glossary

| Term | Definition |
|------|-----------|
| **BEAM** | The Erlang virtual machine that runs Elixir |
| **OTP** | Open Telecom Platform — Erlang's framework for fault tolerance |
| **Umbrella** | Elixir project structure containing multiple OTP apps |
| **LiveView** | Phoenix's server-rendered real-time UI framework |
| **Aggregate** | DDD pattern — a cluster of entities treated as a unit |
| **CQRS** | Command Query Responsibility Segregation |
| **Event Sourcing** | Storing state as a sequence of events |
| **Telemetry** | Erlang's built-in instrumentation library |
| **Kustomize** | Kubernetes-native configuration management |
| **ArgoCD** | GitOps continuous delivery for Kubernetes |
| **ClickHouse** | Columnar OLAP database for analytics |

---

*PulseBoard — Built with Elixir. Designed for compliance. Ready for scale.*
