# devenv-claude

**Claude Code skill for migrating from nix-shell to devenv** — comprehensive guides, templates, and real-world patterns.

---

## Quick Install

### Marketplace (Recommended)

```bash
/plugin marketplace add https://github.com/dz0ny/devenv-claude
/plugin install devenv@devenv-claude
```

### Manual

```bash
git clone https://github.com/dz0ny/devenv-claude.git ~/.claude/skills/devenv-claude
# Restart Claude Code to auto-discover the skill
```

---

## What It Does

Helps you migrate from nix-shell to devenv or create new devenv projects with:

- **Migration guidance**: nix-shell → devenv conversion patterns
- **Language configs**: Python (uv/poetry/venv), JavaScript, Go, Rust, Elm
- **Services**: PostgreSQL, Redis, MySQL, MongoDB, Elasticsearch
- **Process orchestration**: Health checks, dependencies, restart policies
- **Ready-to-use templates**: From basic to full-stack setups
- **Platform-specific solutions**: Linux patchelf, macOS frameworks, WSL

---

## Usage

Claude Code automatically triggers this skill when you:

```
You: "Migrate my nix-shell setup to devenv"
You: "Set up devenv with Python and PostgreSQL"
You: "Why is my devenv build failing?"
```

---

## What's Inside

```
skills/devenv/
├── SKILL.md                  # Main skill (460 lines)
├── references/               # Detailed guides (3,918 lines)
│   ├── migration-guide.md
│   ├── language-configs.md
│   ├── services-guide.md
│   ├── processes-tasks.md
│   └── troubleshooting.md
└── assets/templates/         # Ready configs (769 lines)
    ├── basic-devenv.nix
    ├── python-backend.nix
    ├── fullstack.nix
    └── multi-language.nix
```

**Total**: 5,147 lines of curated devenv knowledge

---

## Real-World Example

Based on real-world migration experience:

**Before** (nix-shell):
- 150+ line `default.nix` with manual setup
- Complex patchelf logic for Linux
- Manual process orchestration

**After** (devenv):
- 80-100 line `devenv.nix`
- Automatic platform handling
- Declarative processes with health checks

**Stack**: Python + uv + PostgreSQL 17 + Redis + Elm + elm-land + Tailwind

---

## Key Gotchas Solved

This skill handles real migration issues discovered during Hakuto conversion:

✅ **PostgreSQL quoting**: SQL `''` vs Nix `''''` syntax
✅ **uv monorepo**: Correct `pyproject.toml` paths
✅ **nixpkgs-python**: Required input for version pinning
✅ **Code generation**: `enterTest` vs `enterShell` timing
✅ **Process dependencies**: One-time tasks with `exit 0`

---

## Documentation

See [skills/devenv/README.md](skills/devenv/README.md) for:
- Detailed skill structure
- Coverage breakdown
- Validation checklist
- Testing recommendations

---

## Links

- **devenv**: [devenv.sh](https://devenv.sh)
- **Claude Code**: [claude.com/claude-code](https://claude.com/claude-code)

---

MIT License
