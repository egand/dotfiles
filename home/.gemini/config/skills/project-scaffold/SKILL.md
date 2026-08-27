---
name: project-scaffold
description: >-
  Scaffold, initialize, or bootstrap a new software project or repository in Python, Go,
  TypeScript, or Java. Enforces multi-editor gitignores (including VS Code and JetBrains),
  pinned runtime versions, modern package management, static analysis, command runner
  (justfile), git pre-commit hooks, and repository AGENTS.md quality guides.
---

# Project Scaffolding Workflow

Follow this procedure whenever initializing a new project or repository.

## Universal 6-Step Workflow

### Step 1: Initialize Git & Multi-Editor `.gitignore`
Always include OS (`macos`), IDE (`visualstudiocode`, `jetbrains`), and language tags so team members across different editors do not pollute git history:

```bash
git init
curl -sL "https://www.toptal.com/developers/gitignore/api/<language>,macos,visualstudiocode,jetbrains" > .gitignore
```

### Step 2: Language-Specific Scaffolding
Read and follow the appropriate language reference guide:
- **Python**: [references/python.md](./references/python.md) (`uv` + `ruff` + `mypy` + `pytest` + `pyright`)
- **Go**: [references/go.md](./references/go.md) (`go mod` + `golangci-lint` + `go test`)
- **TypeScript**: [references/typescript.md](./references/typescript.md) (`pnpm` + `biome`/`eslint` + `vitest`)
- **Java**: [references/java.md](./references/java.md) (`gradle` + `openjdk21` + `spotless` + `junit5`)

### Step 3: Pin Runtime & Tool Versions
Ensure exact versions are pinned in standard dotfiles:
- Python: `.python-version` & `requires-python` in `pyproject.toml`
- Go: `go <version>` directive in `go.mod`
- TypeScript / Node: `.node-version` & `engines` in `package.json`
- Java: `.java-version` & `jvmToolchain(...)` in `build.gradle.kts`

### Step 4: Standardize Command Runner (`justfile`)
Create a `justfile` providing uniform recipes:
- `just check`: Runs lint, format-check, typecheck, and tests in sequence.
- `just fix`: Automatically fixes lint and formatting violations.
- `just test`: Runs the test suite.
- `just pre-commit`: Runs pre-commit hooks on all files.
- `just install-hooks`: Installs git pre-commit hooks locally.

### Step 5: Git Pre-Commit Hooks
Create `.pre-commit-config.yaml` with:
- Standard hygiene: `trailing-whitespace`, `end-of-file-fixer`, `check-yaml`, `check-added-large-files`, `check-merge-conflict`.
- Fast linters / formatters for the target language.
- Run `just install-hooks` to link `.git/hooks/pre-commit`.

### Step 6: Create Project `AGENTS.md`
Generate a root `AGENTS.md` defining:
1. Pinned environment and runtime.
2. Token-efficient verification workflow: targeted unit tests during iteration, commit-time git hook checks, and `just check` upon completion.
3. Engineering standards (zero-lint tolerance, explicit typing).
4. High-level architecture map of the codebase.

