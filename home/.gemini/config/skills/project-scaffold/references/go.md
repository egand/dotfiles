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

  - repo: https://github.com/golangci/golangci-lint
    rev: v1.64.5
    hooks:
      - id: golangci-lint
```

## 4. Command Runner (`justfile`)

```makefile
# Run all quality checks (lint, format check, tests)
check: lint format-check test

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

# Run test suite with race detector
test:
    go test -v -race ./...

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

## 5. Verification
```bash
just install-hooks
just check
```
