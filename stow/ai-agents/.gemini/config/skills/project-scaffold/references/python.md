# Python Project Scaffolding Guide

## 1. Project Initialization with `uv`

```bash
# Initialize repo & multi-editor gitignore
git init
curl -sL "https://www.toptal.com/developers/gitignore/api/python,macos,visualstudiocode,jetbrains" > .gitignore

# Initialize Python project with uv
uv init
echo "3.14" > .python-version

# Add standard development and quality dependencies
uv add --dev ruff mypy pre-commit pytest pytest-asyncio pytest-cov pip-audit
```

## 2. Configuration (`pyproject.toml`)

Add or update the following sections in `pyproject.toml`:

```toml
[tool.ruff]
line-length = 100

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "B",    # flake8-bugbear
    "UP",   # pyupgrade
]
ignore = [
    "E501", # Line length (managed by formatter)
]

[tool.mypy]
python_version = "3.14"
warn_unused_configs = true
warn_unused_ignores = true
check_untyped_defs = true
ignore_missing_imports = true

# NeoVim / Pyright LSP Integration
[tool.pyright]
venvPath = "."
venv = ".venv"
pythonVersion = "3.14"
typeCheckingMode = "standard"
```

## 3. Git Hooks (`.pre-commit-config.yaml`)

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict

  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.24.0
    hooks:
      - id: gitleaks

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.9.9
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
```

## 4. Command Runner (`justfile`)

```makefile
# Run all quality checks (lint, format check, type check, tests, audit)
check: lint format-check typecheck test audit

# Automatically fix linting and formatting issues
fix:
    uv run ruff check --fix .
    uv run ruff format .

# Check code formatting with ruff
format-check:
    uv run ruff format --check .

# Lint code with ruff
lint:
    uv run ruff check .

# Type-check source code with mypy
typecheck:
    uv run mypy src

# Run test suite with coverage
test:
    uv run pytest --cov=src --cov-report=term-missing

# Audit dependencies for security vulnerabilities
audit:
    uv run pip-audit

# Run pre-commit hooks on all files
pre-commit:
    uv run pre-commit run --all-files

# Install pre-commit git hooks
install-hooks:
    uv run pre-commit install
```

## 5. CI/CD Pipeline (`.github/workflows/ci.yml`)

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: extractions/setup-just@v2
      - uses: astral-sh/setup-uv@v5
        with:
          enable-cache: true
      - name: Run verification
        run: just check
```

## 6. Dependabot (`.github/dependabot.yml`)

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
    groups:
      actions:
        patterns:
          - "*"

  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "monthly"
    groups:
      pip-dependencies:
        patterns:
          - "*"
```

## 7. PR Template (`.github/pull_request_template.md`)

```markdown
## Summary
<!-- Brief description of changes -->

## Verification
- [ ] `just check` passes locally
- [ ] Tests added/updated
```

## 8. Containerization (Conditional: Web APIs / Daemons Only)

Only create `Dockerfile` and `.dockerignore` when building deployable web services or daemons:

```dockerfile
# Multi-stage minimal uv build
FROM ghcr.io/astral-sh/uv:python3.14-bookworm-slim AS builder
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

FROM python:3.14-slim AS runner
WORKDIR /app
COPY --from=builder /app/.venv /app/.venv
COPY src ./src
ENV PATH="/app/.venv/bin:$PATH"
USER 65534:65534
CMD ["python", "-m", "src.main"]
```

`.dockerignore`:
```
.git
.venv
__pycache__
*.pyc
.pytest_cache
.mypy_cache
.ruff_cache
tests
```

## 9. Verification
```bash
just install-hooks
just fix
just check
```
