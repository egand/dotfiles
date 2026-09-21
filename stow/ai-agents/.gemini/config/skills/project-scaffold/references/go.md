# Go Project Scaffolding Guide

## 1. Project Initialization

```bash
# Initialize repo & multi-editor gitignore
git init
curl -sL "https://www.toptal.com/developers/gitignore/api/go,macos,visualstudiocode,jetbrains" > .gitignore

# Initialize Go module
go mod init <module_name>
```

## 2. Linter Configuration (`.golangci.yml`)

```yaml
version: "2"
linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
    - gofmt
    - goimports
    - misspell
    - revive

issues:
  exclude-use-default: false
  max-issues-per-linter: 0
  max-same-issues: 0
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

  - repo: https://github.com/golangci/golangci-lint
    rev: v1.64.5
    hooks:
      - id: golangci-lint
```

## 4. Command Runner (`justfile`)

```makefile
# Run all quality checks (lint, format check, tests, audit)
check: lint format-check test audit

# Automatically fix format and imports
fix:
    go fmt ./...
    golangci-lint run --fix ./...

# Check formatting
format-check:
    test -z $(gofmt -l .)

# Run golangci-lint
lint:
    golangci-lint run ./...

# Run test suite with race detector and coverage
test:
    go test -v -race -coverprofile=coverage.out ./...

# Audit dependencies for known vulnerabilities
audit:
    govulncheck ./...

# Run pre-commit hooks on all files
pre-commit:
    pre-commit run --all-files

# Install pre-commit git hooks
install-hooks:
    pre-commit install

# Build binary
build:
    go build -v -o bin/app ./...
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
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
          cache: true
      - name: Install audit & lint tools
        run: |
          curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.64.5
          go install golang.org/x/vuln/cmd/govulncheck@latest
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

  - package-ecosystem: "gomod"
    directory: "/"
    schedule:
      interval: "monthly"
    groups:
      gomod-dependencies:
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
# Multi-stage minimal distroless build
FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/bin/service .

FROM gcr.io/distroless/static-debian12:nonroot AS runner
WORKDIR /app
COPY --from=builder /app/bin/service /app/service
USER nonroot:nonroot
ENTRYPOINT ["/app/service"]
```

`.dockerignore`:
```
.git
bin
coverage.out
.pre-commit-config.yaml
```

## 9. Verification
```bash
just install-hooks
just fix
just check
```
