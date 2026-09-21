# TypeScript Project Scaffolding Guide

## 1. Project Initialization with `pnpm`

```bash
# Initialize repo & multi-editor gitignore
git init
curl -sL "https://www.toptal.com/developers/gitignore/api/node,macos,visualstudiocode,jetbrains" > .gitignore

# Pin Node LTS version
echo "22" > .node-version

# Initialize package.json and install dependencies
pnpm init
pnpm add -D typescript @types/node @biomejs/biome vitest @vitest/coverage-v8
```

## 2. TypeScript Configuration (`tsconfig.json`)

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*", "tests/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## 3. Biome Configuration (`biome.json`)

```json
{
  "$schema": "https://biomejs.dev/schemas/1.9.4/schema.json",
  "vcs": {
    "enabled": true,
    "clientKind": "git",
    "useIgnoreFile": true
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  }
}
```

## 4. Git Hooks (`.pre-commit-config.yaml`)

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

  - repo: local
    hooks:
      - id: biome-check
        name: biome check
        entry: pnpm exec biome check --write
        language: system
        types: [text]
        files: "\\.(jsx?|tsx?|json|jsonc)$"
```

## 5. Command Runner (`justfile`)

```makefile
# Run all quality checks (lint, format check, type check, tests, audit)
check: lint format-check typecheck test audit

# Automatically fix linting and formatting issues
fix:
    pnpm exec biome check --write .

# Check code formatting
format-check:
    pnpm exec biome format .

# Lint code
lint:
    pnpm exec biome lint .

# Type-check source code with tsc
typecheck:
    pnpm exec tsc --noEmit

# Run test suite with coverage
test:
    pnpm exec vitest run --coverage

# Audit dependencies for known vulnerabilities
audit:
    pnpm audit

# Run pre-commit hooks on all files
pre-commit:
    pre-commit run --all-files

# Install pre-commit git hooks
install-hooks:
    pre-commit install

# Build distribution artifacts
build:
    pnpm exec tsc
```

## 6. CI/CD Pipeline (`.github/workflows/ci.yml`)

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
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version-file: .node-version
          cache: pnpm
      - name: Install dependencies
        run: pnpm install --frozen-lockfile
      - name: Run verification
        run: just check
```

## 7. Dependabot (`.github/dependabot.yml`)

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

  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "monthly"
    groups:
      npm-dependencies:
        patterns:
          - "*"
```

## 8. PR Template (`.github/pull_request_template.md`)

```markdown
## Summary
<!-- Brief description of changes -->

## Verification
- [ ] `just check` passes locally
- [ ] Tests added/updated
```

## 9. Containerization (Conditional: Web APIs / Daemons Only)

Only create `Dockerfile` and `.dockerignore` when building deployable web services or daemons:

```dockerfile
# Multi-stage minimal Node/pnpm build
FROM node:22-alpine AS builder
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build

FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile
COPY --from=builder /app/dist ./dist
USER node
CMD ["node", "dist/index.js"]
```

`.dockerignore`:
```
.git
node_modules
dist
coverage
```

## 10. Verification
```bash
just install-hooks
just fix
just check
```
