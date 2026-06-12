# Contributing to PulseBoard

Thank you for your interest in contributing to PulseBoard! This document provides guidelines and instructions for contributing.

## Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Make your changes
4. Run tests: `mix test`
5. Run linter: `mix credo`
6. Run type checker: `mix dialyzer`
7. Commit with a conventional commit message
8. Push and create a Pull Request

## Commit Conventions

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new feature
fix: resolve bug
docs: update documentation
style: formatting changes
refactor: code restructuring
test: add or update tests
chore: maintenance tasks
```

## Code Standards

### Elixir

- Use Credo for linting (`mix credo`)
- Use Dialyzer for type checking (`mix dialyzer`)
- Write `@moduledoc` and `@doc` for public functions
- Use pattern matching over conditionals where possible
- Prefer `with` for multi-step error handling

### Testing

- Write tests for all new features and bug fixes
- Aim for meaningful coverage, not just line coverage
- Use ExUnit and describe/context blocks for organization

### Phoenix/LiveView

- Use HEEx templates with `~H` sigil
- Keep LiveViews thin — delegate business logic to contexts
- Use components for reusable UI elements

## Pull Request Guidelines

- Keep PRs focused on a single change
- Include a clear description of what changed and why
- Reference related issues
- Ensure CI passes before requesting review
- Respond to review feedback promptly

## Architecture Decisions

For significant architectural changes, create an Architecture Decision Record (ADR) in the `docs/adrs/` directory. See [ARCHITECTURE.md](ARCHITECTURE.md) for the ADR template.

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## Questions?

Open an issue or start a discussion on GitHub.
