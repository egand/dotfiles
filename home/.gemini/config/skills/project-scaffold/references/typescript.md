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
pnpm add -D typescript @types/node @biomejs/biome vitest
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
# Run all quality checks (lint, format check, type check, tests)
check: lint format-check typecheck test

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

# Run test suite
test:
    pnpm exec vitest run

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

## 6. Verification
```bash
just install-hooks
just fix
just check
```
