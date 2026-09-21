# Java Project Scaffolding Guide

## 1. Project Initialization with Gradle Kotlin DSL

```bash
# Initialize repo & multi-editor gitignore
git init
curl -sL "https://www.toptal.com/developers/gitignore/api/gradle,java,macos,visualstudiocode,jetbrains" > .gitignore

# Pin Java LTS version
echo "21" > .java-version

# Initialize Gradle wrapper and build structure
gradle init --type java-application --dsl kotlin --test-framework junit-jupiter
```

## 2. Build Configuration (`build.gradle.kts`)

Ensure `build.gradle.kts` includes Java 21 toolchain, JaCoCo, and Spotless plugin for zero-drift formatting:

```kotlin
plugins {
    java
    application
    jacoco
    id("com.diffplug.spotless") version "7.0.2"
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

spotless {
    java {
        googleJavaFormat("1.25.2")
        removeUnusedImports()
        trimTrailingWhitespace()
        endWithNewline()
    }
}

tasks.named<Test>("test") {
    useJUnitPlatform()
    finalizedBy(tasks.jacocoTestReport)
}

tasks.jacocoTestReport {
    dependsOn(tasks.test)
    reports {
        xml.required.set(true)
        html.required.set(true)
    }
}
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

  - repo: local
    hooks:
      - id: spotless-check
        name: spotless check
        entry: ./gradlew spotlessCheck
        language: system
        files: "\\.java$"
        pass_filenames: false
```

## 4. Command Runner (`justfile`)

```makefile
# Run all quality checks (spotless check, build, tests with coverage)
check: lint test

# Automatically fix formatting issues with Spotless
fix:
    ./gradlew spotlessApply

# Lint code formatting with Spotless
lint:
    ./gradlew spotlessCheck

# Run test suite with JaCoCo coverage report
test:
    ./gradlew test jacocoTestReport

# Run pre-commit hooks on all files
pre-commit:
    pre-commit run --all-files

# Install pre-commit git hooks
install-hooks:
    pre-commit install

# Build jar / distribution
build:
    ./gradlew build
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
      - actions/setup-java@v4
        with:
          distribution: temurin
          java-version-file: .java-version
          cache: gradle
      - name: Make Gradle wrapper executable
        run: chmod +x gradlew
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

  - package-ecosystem: "gradle"
    directory: "/"
    schedule:
      interval: "monthly"
    groups:
      gradle-dependencies:
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
# Multi-stage minimal JRE build
FROM gradle:8.12-jdk21-alpine AS builder
WORKDIR /app
COPY build.gradle.kts settings.gradle.kts ./
COPY src ./src
RUN gradle build --no-daemon -x test

FROM eclipse-temurin:21-jre-alpine AS runner
WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar
USER 65534:65534
ENTRYPOINT ["java", "-jar", "app.jar"]
```

`.dockerignore`:
```
.git
.gradle
build
bin
```

## 9. Verification
```bash
just install-hooks
just fix
just check
```
