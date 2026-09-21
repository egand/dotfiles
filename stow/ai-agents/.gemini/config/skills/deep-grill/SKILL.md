---
name: deep-grill
description: >-
  Interactive architectural interview that walks down the design tree one question at a time,
  with automatic pausing and deep-dive exploration whenever the user is uncertain.
---

# Grill-Me (with Consultative Deep-Dive)

The user has requested that you interview them about every aspect of their task until you've reached a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

## Guidelines:
- Ask questions one at a time.
- If a question can be answered by exploring the codebase, explore the codebase instead.
- For normal decision gates where the user has sufficient context, use the `ask_question` tool.

## Critical Deep-Dive Rule (When User is Uncertain or Asks for Details):
When the user expresses uncertainty, says "I don't know", asks for a comparison, or asks questions about how something works:
1. **Never jump directly to an `ask_question` modal without writing the explanation first.**
2. **Output a visible Markdown deep-dive in your chat response:**
   - Address their direct questions explicitly (e.g. costs, hosting, mechanics).
   - Provide a clear comparison table or structured breakdown of the options with concrete pros and cons.
   - Give an opinionated recommendation and clear rationale.
3. At the end of that explanatory response, provide the decision options (via `ask_question` or prompt) to let the user choose with full context.
