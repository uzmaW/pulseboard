# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in PulseBoard, please report it responsibly.

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, please email security@pulseboard.dev with:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

We will acknowledge receipt within 48 hours and provide a resolution timeline within 7 days.

## Security Measures

- RBAC with audit trails for all sensitive actions
- Vault-backed secrets with tenant isolation
- Impersonation sessions are fully logged with admin ID and reason
- Regional compliance policies enforce data retention and consent
- CI pipeline includes security scanning

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x | Yes |
| < 1.0 | No |
