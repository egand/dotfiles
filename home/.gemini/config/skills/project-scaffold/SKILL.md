---
name: project-scaffold
description: >-
  Scaffold, initialize, or bootstrap a new software project or repository in Python, Go,
  TypeScript, or Java. Enforces multi-editor gitignores and .editorconfig, pinned runtime
  versions, modern package management, static analysis, command runner (justfile), git
  pre-commit hooks with secret scanning, GitHub Actions CI/CD, Dependabot, PR templates,
  and repository AGENTS.md quality guides.
---

# Project Scaffolding Workflow

Follow this procedure whenever initializing a new project or repository.

## Universal 7-Step Workflow

### Step 1: Initialize Git, Multi-Editor `.gitignore`, and `.editorconfig`
Always include OS (`macos`), IDE (`visualstudiocode`, `jetbrains`), and language tags:

```bash
git init
curl -sL "https://www.toptal.com/developers/gitignore/api/<language>,macos,visualstudiocode,jetbrains" > .gitignore
```

Create a root `.editorconfig` to enforce consistent editor settings across all IDEs:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 4

[*.{ts,tsx,js,jsx,json,jsonc,yml,yaml,md,toml}]
indent_size = 2

[*.go]
indent_style = tab
indent_size = 4

[Makefile]
indent_style = tab
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
Create a `justfile` providing uniform recipes across all languages:
- `just check`: Runs lint, format-check, typecheck, and tests in sequence.
- `just fix`: Automatically fixes lint and formatting violations.
- `just test`: Runs the test suite.
- `just pre-commit`: Runs pre-commit hooks on all files.
- `just install-hooks`: Installs git pre-commit hooks locally.

### Step 5: Git Pre-Commit Hooks & Secret Scanning
Create `.pre-commit-config.yaml` with:
- Standard hygiene: `trailing-whitespace`, `end-of-file-fixer`, `check-yaml`, `check-added-large-files`, `check-merge-conflict`.
- Secret scanning: [gitleaks](https://github.com/gitleaks/gitleaks) hook to prevent committing credentials.
- Fast linters / formatters for the target language.
- Run `just install-hooks` to link `.git/hooks/pre-commit`.

### Step 6: CI/CD, Dependabot & PR Templates
Create GitHub workflows and templates:
1. **CI Pipeline (`.github/workflows/ci.yml`)**: Trigger on `push` to `main` and `pull_request`, install toolchains with caching, and run `just check`.
2. **Dependabot (`.github/dependabot.yml`)**: Automated weekly dependency checks for `github-actions` and language package managers.
3. **PR Template (`.github/pull_request_template.md`)**: PR checklist confirming `just check` passed.

### Step 7: Project Documentation & `AGENTS.md`
Generate baseline repository documentation:
1. `README.md` with project overview, prerequisites, and quickstart commands (`just check`, `just test`).
2. `LICENSE` (e.g. MIT / Apache-2.0 / Proprietary).
3. `.env.example` if environment configuration is required.
4. Root `AGENTS.md` defining:
   - Pinned environment and runtime.
   - Token-efficient verification workflow: targeted unit tests during iteration, commit-time git hook checks, and `just check` upon completion.
   - Engineering standards (zero-lint tolerance, explicit typing).
   - High-level architecture map of the codebase.

