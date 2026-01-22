---
name: devenv-migration
description: Migrate from nix-shell to devenv or create new devenv projects. Use when users mention converting shell.nix/default.nix to devenv, setting up devenv environments, or need help with devenv configuration for languages (Python, Elm, Node, etc), services (PostgreSQL, Redis, MySQL), or processes.
---

# devenv Migration Skill

Convert nix-shell projects to devenv or create new devenv environments with declarative configuration for languages, services, and processes.

## What is devenv?

**devenv** is a declarative development environment tool built on Nix that provides:

- **Integrated service management**: PostgreSQL, Redis, MySQL run as managed processes
- **Process orchestration**: Dev servers, watchers, and workers in one configuration
- **Better isolation**: Services use project-local data directories
- **Simplified setup**: Single `devenv.nix` replaces multiple configuration files
- **Pre-commit integration**: Declarative git hooks
- **Task system**: Define build, test, and deployment tasks

## When to Use This Skill

Trigger this skill when users:
- Want to migrate from nix-shell to devenv
- Need help configuring devenv.nix
- Ask about setting up languages (Python, JavaScript, Elm, Go, Rust)
- Need service configuration (PostgreSQL, Redis, MySQL, etc.)
- Want to configure processes or tasks
- Have issues with devenv setup
- Ask about converting process-compose.yml to devenv
- Need help with platform-specific issues (Linux patchelf, macOS frameworks)

## Quick Start

### New Project

```bash
# Install devenv
nix profile install nixpkgs#devenv

# Initialize in project directory
cd your-project
devenv init

# Enter environment
devenv shell

# Start services and processes
devenv up
```

### Migration from nix-shell

See [Migration Guide](./references/migration-guide.md) for detailed conversion patterns.

**Quick conversion:**
1. Read existing shell.nix/default.nix
2. Map buildInputs to languages.* and packages
3. Convert shellHook to enterShell
4. Replace manual service setup with services.*
5. Convert process-compose.yml to processes
6. Test with `devenv shell` and `devenv up`

## Core Concepts

### Configuration Structure

```nix
{ pkgs, ... }:

{
  # Tools and utilities
  packages = [ pkgs.git pkgs.jq ];

  # Language runtimes
  languages.python.enable = true;
  languages.javascript.enable = true;

  # Managed services
  services.postgres.enable = true;
  services.redis.enable = true;

  # Long-running processes
  processes.backend.exec = "uvicorn app:app --reload";

  # One-time tasks
  scripts.test.exec = "pytest";

  # Git hooks (171 built-in hooks available)
  git-hooks.hooks = {
    ruff-format.enable = true;
    prettier.enable = true;
  };

  # Environment variables
  env.DATABASE_URL = "postgresql:///mydb?host=$PGHOST";

  # Shell initialization
  enterShell = ''
    echo "Environment ready!"
  '';
}
```

### Key Differences from nix-shell

| nix-shell | devenv |
|-----------|--------|
| `buildInputs` | `packages` + `languages.*` |
| `shellHook` | `enterShell` |
| Manual service setup | `services.*` |
| process-compose.yml | `processes` |
| Makefile tasks | `scripts` |
| .pre-commit-config.yaml | `git-hooks.hooks.*` (171 built-in hooks) |

## Navigation

### Reference Guides

Detailed documentation on specific topics:

- **[Migration Guide](./references/migration-guide.md)** - Step-by-step conversion from nix-shell
  - Why migrate
  - Basic conversion patterns (mkShell → devenv.nix)
  - Flakes integration
  - Complex migrations (Hakuto example)
  - Step-by-step migration process
  - Common pitfalls

- **[Language Configurations](./references/language-configs.md)** - Setting up programming languages
  - Python (venv, uv, poetry, PYTHONPATH)
  - JavaScript/Node (npm, yarn, pnpm)
  - Elm (elm-land integration)
  - Go, Rust
  - Multi-language projects
  - Platform-specific issues (Linux patchelf, macOS frameworks)

- **[Services Guide](./references/services-guide.md)** - Database and service setup
  - PostgreSQL (versions, initialization, configuration)
  - Redis (persistence, configuration)
  - MySQL, MongoDB, Elasticsearch, RabbitMQ
  - Service management (start, stop, logs, health checks)
  - Migrating from process-compose.yml

- **[Processes and Tasks](./references/processes-tasks.md)** - Process orchestration and scripts
  - Process definition and configuration
  - Dependencies and health checks
  - Restart policies
  - Migrating from process-compose.yml
  - Scripts for one-time tasks
  - Common patterns (fullstack, API + worker, etc.)

- **[Git Hooks Guide](./references/git-hooks-guide.md)** - Pre-commit hook configuration
  - Built-in hooks vs custom hooks (171 available)
  - Migration from Python Nix packages to prek
  - Common patterns (Python, JavaScript, Nix, fullstack)
  - Hook configuration (stages, file matching, exclusions)
  - Language-specific hooks (Python, JavaScript, Go, Rust, Nix, etc.)
  - Troubleshooting and best practices

- **[Advanced Patterns](./references/advanced-patterns.md)** - Production-tested patterns
  - One-time initialization processes (db-init pattern)
  - Custom health checks (role verification, HTTP, TCP, command-based)
  - Process dependency chains and conditions
  - Advanced PostgreSQL setup (multiple databases, roles, extensions)
  - Python virtual environment management (PYTHONPATH, VIRTUAL_ENV)
  - Conditional builds and inline dependencies
  - Frontend build patterns (OpenAPI generation, conditional builds)
  - enterTest vs enterShell usage
  - Common gotchas and solutions

- **[Troubleshooting](./references/troubleshooting.md)** - Common issues and solutions
  - Migration issues
  - Platform-specific problems
  - Service startup failures
  - Language-specific errors
  - Performance issues
  - Debugging tips

### Templates

Ready-to-use devenv configurations:

- **[basic-devenv.nix](./assets/templates/basic-devenv.nix)** - Minimal starter template
- **[python-backend.nix](./assets/templates/python-backend.nix)** - Python + uv + PostgreSQL + Redis
- **[fullstack.nix](./assets/templates/fullstack.nix)** - Backend (Python) + Frontend (Elm) + services
- **[multi-language.nix](./assets/templates/multi-language.nix)** - Python + JavaScript + Go
- **[devenv.yaml](./assets/templates/devenv.yaml)** - Nixpkgs inputs configuration

## Common Use Cases

### 1. Migrate Existing Project

**User has:** shell.nix or default.nix with buildInputs

**Steps:**
1. Read [Migration Guide](./references/migration-guide.md)
2. Analyze current setup (languages, services, shellHook)
3. Create devenv.nix using appropriate template
4. Convert buildInputs → packages/languages
5. Convert shellHook → enterShell
6. Test with `devenv shell`

### 2. Setup Python Backend

**User wants:** Python + PostgreSQL + Redis

**Steps:**
1. Use [python-backend.nix](./assets/templates/python-backend.nix) template
2. Customize database names, ports
3. Configure Python version and uv settings
4. Add project-specific scripts
5. Reference [Language Configurations](./references/language-configs.md) for Python details

### 3. Setup Fullstack Application

**User wants:** Backend + Frontend + services

**Steps:**
1. Use [fullstack.nix](./assets/templates/fullstack.nix) template
2. Customize for specific frontend framework
3. Configure API client generation if needed
4. Set up process dependencies
5. Reference [Processes and Tasks](./references/processes-tasks.md) for orchestration

### 4. Add Service to Existing Setup

**User wants:** Add PostgreSQL to existing devenv.nix

**Steps:**
1. Read [Services Guide](./references/services-guide.md) for PostgreSQL
2. Add service configuration to devenv.nix
3. Add environment variables for connection
4. Update process dependencies
5. Test with `devenv up`

### 5. Setup Git Hooks

**User wants:** Pre-commit hooks for code quality

**Steps:**
1. Read [Git Hooks Guide](./references/git-hooks-guide.md)
2. Add `git-hooks.hooks.*` to devenv.nix
3. Choose from 171 available built-in hooks
4. Configure stages (pre-commit vs pre-push)
5. Test with `devenv shell --command "pre-commit run --all-files"`

### 6. Troubleshoot Issues

**User has:** Errors or unexpected behavior

**Steps:**
1. Read [Troubleshooting](./references/troubleshooting.md)
2. Check platform-specific issues (Linux, macOS, WSL)
3. Verify service logs in `.devenv/state/`
4. Use verbose mode: `devenv shell -vvv`
5. Isolate issue with minimal configuration

## Instructions for Claude

When using this skill:

### 1. Understand User Intent

**Identify the task:**
- New project setup → Use templates
- Migration from nix-shell → Read their config, use Migration Guide
- Adding feature → Reference specific guide
- Debugging → Check Troubleshooting

### 2. Read Relevant Context

**For migrations:**
- Read user's shell.nix/default.nix/process-compose.yml
- Identify languages, services, processes
- Check for complex patterns (custom derivations, platform-specific logic)

**For new projects:**
- Ask about requirements (languages, services, processes)
- Choose appropriate template

### 3. Provide Specific Guidance

**Use references for detail:**
- Don't repeat reference content verbatim
- Point to specific sections: "See Migration Guide > Converting shellHook"
- Provide quick summary + reference link

**Use templates as starting points:**
- Copy template content
- Customize for user's needs
- Explain key sections

### 4. Handle Complexity

**Simple cases (basic Python + PostgreSQL):**
- Use template directly with minimal changes

**Complex cases (Hakuto-level):**
- Break down into steps
- Reference Migration Guide for patterns
- Address platform-specific concerns
- Explain tradeoffs

### 5. Validate and Test

**Always include:**
- How to test the configuration (`devenv shell`, `devenv up`)
- Expected outcomes
- How to verify services are running

### 6. Troubleshoot Proactively

**Anticipate issues:**
- Linux users → Mention patchelf for Python
- macOS users → Note framework differences
- PostgreSQL → Explain socket vs TCP connection
- Python → Remind to unset PYTHONPATH

## Real-World Example: Hakuto Migration

The Hakuto project provides a realistic example of complex nix-shell → devenv migration:

**Before:** 150+ lines across:
- default.nix: Python + Elm tooling, custom derivations (OpenAPI client, frontend dist build)
- backend/process-compose.yml: PostgreSQL + Redis
- frontend/process-compose.yml: elm-land + tailwindcss watchers

**After:** ~80-100 lines in devenv.nix with:
- Declarative services (PostgreSQL 17, Redis)
- Process orchestration (backend, frontend-dev, frontend-css)
- Scripts for API client generation, testing, demo
- Platform-specific patchelf logic for Linux
- Pre-commit hooks

**Key patterns from Hakuto:**
- One-time db-init process with `availability.restart = "no"`
- Custom PostgreSQL health check verifying role existence
- Process dependency chain: services → init → application
- Python + uv with PYTHONPATH management and VIRTUAL_ENV export
- Elm + elm-land + Tailwind CSS integration with TTY control
- PostgreSQL 17 with multiple databases, roles, and extensions
- OpenAPI client generation in enterShell
- Conditional frontend build (only if dist missing)
- Inline build dependencies in process exec
- Playwright browser path configuration
- HTTP readiness probe for backend
- Linux-specific patchelf for Python wheels

See [fullstack.nix](./assets/templates/fullstack.nix) template for complete example.

## Best Practices

### 1. Progressive Disclosure

Start simple, add complexity as needed:
1. Languages and tools
2. Services
3. Processes
4. Scripts
5. Platform-specific logic

### 2. Use Templates

Don't write from scratch:
- Start with appropriate template
- Customize incrementally
- Test at each step

### 3. Explicit Dependencies

Declare process dependencies on services:
```nix
processes.backend = {
  exec = "uvicorn app:app --reload";
  process-compose.depends_on.postgres.condition = "process_healthy";
};
```

### 4. Health Checks

Define health checks for critical services:
```nix
processes.api = {
  exec = "uvicorn app:app";
  process-compose.readiness_probe.http_get = {
    host = "localhost";
    port = 8000;
    path = "/health";
  };
};
```

### 5. Platform Awareness

Handle platform differences:
```nix
enterTest = pkgs.lib.optionalString pkgs.stdenv.isLinux ''
  # Linux-specific patchelf
'';
```

### 6. Documentation

Comment complex sections:
```nix
# Required for PostgreSQL 17's generated columns feature
services.postgres.package = pkgs.postgresql_17;
```

## Command Reference

### Basic Commands

```bash
# Initialize devenv
devenv init

# Enter shell
devenv shell

# Start all processes
devenv up

# Start specific processes
devenv up backend frontend

# Start in background
devenv up -d

# Stop processes
devenv processes stop

# Run script
devenv shell test

# Show configuration
devenv info

# Update lock file
devenv update
```

### Debugging

```bash
# Verbose mode
devenv shell -vvv

# Check syntax
nix-instantiate --parse devenv.nix

# View process logs
tail -f .devenv/state/process-compose/logs/backend.log

# Check service status
devenv info
```

## Getting More Help

### Latest Documentation

For up-to-date API reference and new features:
- Use Context7 to fetch latest devenv docs: `/cachix/devenv`
- Official docs: https://devenv.sh
- GitHub: https://github.com/cachix/devenv

### Bundled Content

This skill bundles:
- Migration patterns and common configurations
- Real-world examples from Hakuto project
- Platform-specific solutions
- Troubleshooting guides

### When to Fetch Latest Docs

Use Context7 for:
- New devenv features
- Recently added services or options
- Updated language support
- Breaking changes in new versions

## Summary

This skill helps with:
- ✅ Migrating from nix-shell to devenv
- ✅ Setting up new devenv projects
- ✅ Configuring languages (Python, JavaScript, Elm, Go, Rust)
- ✅ Managing services (PostgreSQL, Redis, MySQL, etc.)
- ✅ Orchestrating processes and tasks
- ✅ Setting up git hooks (171 built-in hooks available)
- ✅ Solving platform-specific issues
- ✅ Debugging devenv configurations

**Start here:**
1. Identify user's goal (new project, migration, add feature, debug)
2. Choose appropriate template or reference guide
3. Customize for their specific needs
4. Test and iterate

**Remember:** Keep it simple, use templates, reference guides for details, and test incrementally.
