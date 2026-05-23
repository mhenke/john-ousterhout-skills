# ADR-003: Skill Routing for Fix Implementation

**Date:** 2026-05-23
**Status:** Accepted
**Applies to:** `skills/aposd-critique/SKILL.md`, `skills/aposd-audit/SKILL.md`, `skills/aposd/SKILL.md`

## Context

After `aposd critique` or `aposd audit` presented findings, both skills offered to fix the issues in-session: "You can ask me to address these one at a time, all at once, or in any order you prefer." This had two problems:

1. The fix was applied in the same context as the analysis, which mixed evaluation and implementation concerns.
2. The fix didn't go through the standalone `aposd` skill's 15 behavioral rules, so fixes might not follow APOSD design principles.

## Decision

Replace in-session self-fixing with **skill routing** — the critique/audit reports end with explicit instructions to load the standalone `aposd` skill for implementation:

> To fix using APOSD design principles, load the `aposd` skill. It applies the 15 APOSD behavioral rules during implementation. Address findings in the priority order above.

The standalone `aposd` skill is the appropriate tool for implementation because it contains the 15 behavioral rules (Strategic Over Tactical, Design Deep Modules, Information Hiding, etc.) that should guide every code modification.

## Rationale

- Separation of concerns: critique/audit = evaluate, `aposd` skill = implement
- Fixes go through the 15 APOSD behavioral rules, ensuring strategic rather than tactical changes
- Follows impeccable's pattern: critique routes to `polish`/`harden` commands rather than self-fixing
- User has clear next-step guidance without needing to re-prompt

## Consequences

- Users must explicitly load the `aposd` skill to fix findings (one extra step)
- Fixes are more likely to be strategic (following the 15 rules) rather than tactical patches
- The `aposd` skill must be well-triggered (see ADR-004)
