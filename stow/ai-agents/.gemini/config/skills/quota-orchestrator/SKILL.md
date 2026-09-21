---
name: quota-orchestrator
description: Inspect remaining Antigravity weekly and 5-hour quota pools, evaluate capacity before starting autonomous workloads, and safely consume excess quota on background tasks (second-brain gardening, research, repository maintenance).
---

# Antigravity Quota Orchestrator

This skill teaches the agent how to inspect live quotas via **MCP (`antigravity-quota`)** or **CLI (`agy-quota`)**, and aggressively drain remaining capacity when instructed by the user.

---

## 1. Triggering Quota Consumption

When the user gives instructions like:
- *"Use all my quota until the refresh, leave nothing left"*
- *"Drain my remaining 5h and weekly quota on PC optimizations and second-brain"*
- *"Spend my tokens overnight on research, repository maintenance, and gardening"*

---

## 2. Core Operational Rules & Subagents

1. **Complete Quota Exhaustion (Zero Residual Target)**:
   - When the user asks to drain all quota, the agent must drive remaining quota down to ~0% (not leaving 10% or headroom).
   - If weekly quota remains but the 5-hour window is exhausted, use the `schedule` tool with `DurationSeconds=<seconds_until_reset>` to automatically sleep and resume execution across multiple 5-hour cycles until the weekly limit or specified deadline (e.g. midnight) is reached.

2. **Permitted Subagent Models**:
   - Only spawn subagents with **Claude Opus** (`Model: "pro"`) or **Gemini 3.7 Flash** (`Model: "flash"` or `"inherit"`). Do not invoke other models.

3. **Non-Destructive Project Work & PRs**:
   - Never break working repositories or modify `main` branch unsafely.
   - For all improvements, refactors, test fixes, and features, create dedicated git feature branches (`feature/...` or `fix/...`) and prepare clean commits / pull requests.

---

## 3. Execution Workflow & Workload Targets

### Workload A: PC & System Optimizations (Audit -> Report -> Gated Execution)
1. **Comprehensive System Profiling**:
   - Inspect macOS disk usage, developer caches (`npm`, `pnpm`, `uv`, `cargo`, `brew`, `docker`).
   - Audit launch agents, background processes, memory pressure, and build artifacts.
2. **Mandatory Second-Brain Report First**:
   - Before executing any optimization or cleanup commands, compile a detailed, structured audit report:
     - Identified bottlenecks, storage reclaim opportunities, and performance gains.
     - Exact commands and actions proposed.
   - Save this report permanently in the user's second-brain repository (`/Users/egand/Developer/projects/second-brain/content/03_ai_learnings/pc_system_optimizations_report.md`).
   - Do NOT execute destructive system changes until the report is recorded.

### Workload B: Second-Brain Knowledge Gardening (`/Users/egand/Developer/projects/second-brain`)
- Scan orphan notes, dead wikilinks, formatting flaws, and tag hygiene.
- Generate and refine Markmap mindmaps, KaTeX math formulas, and Mermaid architecture diagrams.
- Synthesize academic materials, AI learning notes, and concept indexes following `content/05_templates/`.
- Validate site build with `just check` (`tsc --noEmit`, `node scripts/check-diagrams.mjs`, `prettier`, `quartz build`).

### Workload C: Engineering Excellence & Repository Maintenance
- Run test suites and static analysis across all local projects (`zenspec`, `agent-telegram-bridge`, `agy-quota`).
- Upgrade dependencies safely, improve test coverage, fix linter warnings, and remove dead code.
- Commit modular changes to feature branches with conventional commit messages (never adding agent names as co-author).

---

## 4. Multi-Cycle Rescheduling Protocol

1. Query live quota via `get_antigravity_quota(format="json")`.
2. Record `seconds_until_reset` for 5h and weekly buckets.
3. If 5h limit reaches < 3% but weekly quota remains and the session is running under `/goal` or an overnight task:
   - Call `schedule(DurationSeconds=seconds_until_reset, Prompt="Resume autonomous quota consumption for next cycle")`.
   - Conclude active turn; execution will automatically wake up upon timer trigger.

