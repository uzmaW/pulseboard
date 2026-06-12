# Changelog

All notable changes to PulseBoard will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial project architecture and design documentation
- Umbrella app structure with 8 sub-apps
- Domain models: RealtimeSession, ImpersonationSession, Tenant, CompliancePolicy
- RBAC model with Role, Permission, Assignment structs
- Tenant onboarding flow with Vault and LiveKit integration
- LiveView frontend scaffolding (TenantFormLive, ImpersonateLive, SessionLive, DashboardLive)
- Absinthe GraphQL schema with role assignment mutation
- Terraform configuration for Vault secrets management
- Kustomize overlays for multi-tenant Grafana dashboards
- ArgoCD GitOps application manifests
- GitHub Actions CI pipeline (Elixir 1.15, OTP 26, credo, dialyzer)
- OpenTelemetry observability hooks
- Seed script for tenant provisioning
