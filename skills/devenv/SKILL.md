---
name: devenv-migration
description: Migrate from nix-shell to devenv or create new devenv projects. Use when users mention converting shell.nix/default.nix to devenv, setting up devenv environments, or need help with devenv configuration for languages (Python, Elm, Node, etc), services (PostgreSQL, Redis, MySQL), or processes.
---

# devenv Migration Skill

Convert nix-shell projects to devenv or create new devenv environments with declarative configuration for languages, services, and processes.

**Official devenv.nix Options Reference**: https://github.com/cachix/devenv/blob/main/docs/src/reference/options.md

## What is devenv?

**devenv** is a declarative development environment tool built on Nix that provides:

- **Integrated service management**: PostgreSQL, Redis, MySQL run as managed processes
- **Process orchestration**: Dev servers, watchers, and workers in one configuration
- **Better isolation**: Services use project-local data directories
- **Simplified setup**: Single `devenv.nix` replaces multiple configuration files
- **Pre-commit integration**: Declarative git hooks (170+ built-in)
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
| Manual service setup | `services.*` (auto-managed) |
| process-compose.yml | `processes` |
| Makefile tasks | `scripts` |
| .pre-commit-config.yaml | `git-hooks.hooks.*` (170+ built-in) |

## Reference Documentation

### Quick Reference

**[devenv.nix Options](./references/devenv-options.md)** - Common configuration patterns and official options reference

### Detailed Guides

**By Topic:**

- **[Migration Guide](./references/migration-guide.md)** - Converting from nix-shell to devenv
  - Basic patterns (mkShell → devenv.nix), flakes integration, complex migrations

- **[Language Configurations](./references/language-configs.md)** - Language-specific setup
  - Python (venv, uv, poetry), JavaScript/Node, Elm, Go, Rust, multi-language projects

- **[Services Guide](./references/services-guide.md)** - Database and service configuration
  - PostgreSQL, Redis, MySQL, MongoDB, Elasticsearch - setup and management

- **[Processes and Tasks](./references/processes-tasks.md)** - Process orchestration
  - Dependencies, health checks, restart policies, common patterns

- **[Git Hooks Guide](./references/git-hooks-guide.md)** - Pre-commit integration
  - 170+ built-in hooks, custom hooks, language-specific configurations

- **[Advanced Patterns](./references/advanced-patterns.md)** - Production patterns
  - One-time init, custom health checks, complex dependencies, gotchas

- **[Troubleshooting](./references/troubleshooting.md)** - Common issues and solutions
  - Platform-specific problems, service failures, debugging tips

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
1. Check [Troubleshooting](./references/troubleshooting.md) for common issues
2. Verify service logs in `.devenv/state/`
3. Use verbose mode: `devenv shell -vvv`
4. Isolate with minimal configuration

## How to Use This Skill

### 1. Understand User Intent

- **New project** → Use templates
- **Migration** → Read their config, apply patterns from Migration Guide
- **Add feature** → Reference specific guide (Languages, Services, Processes)
- **Debug** → Check Troubleshooting guide

### 2. Gather Context

**For migrations:**
- Read shell.nix/default.nix/process-compose.yml
- Identify languages, services, processes, platform-specific logic

**For new projects:**
- Confirm requirements (languages, services, processes)
- Select appropriate template

### 3. Provide Guidance

- Point to specific reference sections, don't repeat verbatim
- Use templates as starting points, customize for user's needs
- Include test instructions (`devenv shell`, `devenv up`)

### 4. Anticipate Platform Issues

- Linux → patchelf for Python wheels
- macOS → Framework differences
- PostgreSQL → Socket vs TCP connections
- Python → Unset PYTHONPATH before entering shell

## Additional Resources

**Official Documentation:**
- Options reference: https://github.com/cachix/devenv/blob/main/docs/src/reference/options.md
- Website: https://devenv.sh
- GitHub: https://github.com/cachix/devenv

**For latest features:** Use Context7 to fetch current docs: `/cachix/devenv`

## Quick Reference

**Common Commands:**
```bash
devenv init              # Initialize new project
devenv shell             # Enter environment
devenv up                # Start all processes
devenv up -d             # Start in background
devenv shell <script>    # Run script
devenv info              # Show config
devenv shell -vvv        # Debug mode
```

**This skill provides:**
- Migration patterns (nix-shell → devenv)
- Ready-to-use templates
- Language/service/process configuration guides
- Platform-specific solutions (Linux patchelf, macOS frameworks)
- Troubleshooting patterns

**Workflow:**
1. Identify goal → 2. Select template/guide → 3. Customize → 4. Test incrementally
