# ADR-005: Intentional Condensation — CLAUDE.md vs SKILL.md

**Date:** 2026-05-23
**Status:** Accepted
**Applies to:** `CLAUDE.md`, `skills/aposd/SKILL.md`, `.cursor/rules/aposd-guidelines.mdc`

## Context

Three files contain the 15 APOSD behavioral rules:

- **`CLAUDE.md`** — Full-text version for project root. Read once, not in active session context.
- **`skills/aposd/SKILL.md`** — Always-on skill loaded into every coding session. Context cost is a concern.
- **`.cursor/rules/aposd-guidelines.mdc`** — Cursor project rule, mirrors CLAUDE.md body.

`CLAUDE.md`'s header declares: *"Source of truth for the 15 behavioral rules. Copy changes here first, then propagate."* This implies they should be identical, but they aren't:

| Rule | CLAUDE.md | SKILL.md | Diff |
|------|-----------|----------|------|
| 1 | "about how you think, not how long you spend" | omitted | CLAUDE.md has full insight |
| 7 | "Ousterhout reports spending 50-80%" statistic | omitted | SKILL.md drops the statistic |
| 9 | "it IS complicated, and that's your problem to fix" | "that's your problem to fix" | SKILL.md is terser |
| 9 | "before marking code complete" | omitted | SKILL.md drops timing guidance |
| 2 | "Is this easy to use for my current need?" | omitted | SKILL.md drops 2nd diagnostic question |

Additionally, SKILL.md has unique sections not in CLAUDE.md (Quick Reference, Common Mistakes, Routing Rules, Rationalization Table). `.cursor/rules` mirrors CLAUDE.md's body nearly identically.

A sync script or build step (ADR concept discussed) would restore parity but adds maintenance overhead to a small project and requires a commit hook or manual step to enforce.

## Decision

The condensation is **intentional and should remain**. SKILL.md is always-on in every coding session — it must be concise to minimize context consumption. CLAUDE.md is read rarely (project setup) and can carry the full depth. `.cursor/rules` mirrors CLAUDE.md because Cursor has no per-session context cost issue.

Not a decision *for* drift, but a decision *against* tool-enforced synchronization. The relationship is:

- **`CLAUDE.md`** = full depth, design rationale, supporting statistics. For setup and reference.
- **`.cursor/rules/aposd-guidelines.mdc`** = identical body to CLAUDE.md (Cursor platform).
- **`skills/aposd/SKILL.md`** = condensed principles + always-on sections (Quick Reference, Routing Rules, Rationalization Table, Common Mistakes). For active session use.
- **Maintainer practice**: edit CLAUDE.md first, then manually extract the essential guidance into SKILL.md's principle sections, maintaining SKILL.md's conciseness.

## Rationale

- **Session context is real.** SKILL.md is already 1333 words (ADR-004 flagged this). Restoring full text would push ~1700 words. Every token counts in agent context limits.
- **Different audiences, different needs.** CLAUDE.md readers are setting up the project — they benefit from Ousterhout's 50-80% statistic. SKILL.md readers are in an active coding session — they need the principle, not the book citation.
- **Build steps for a 3-file project are over-engineering.** A sync script would be maintained longer than it saves. The manual sync takes 30 seconds after editing.
- **Diff is detectable.** A maintainer reviewing a PR for CLAUDE.md changes can check SKILL.md independently. The diff is small enough to eyeball.
- **No unknown unknowns.** Unlike information leakage in application code, the drift here is visible and documented. A reader comparing the files will see the differences and understand they're intentional.

## Consequences

- CLAUDE.md and SKILL.md will continue to diverge in wording, on purpose.
- Maintainers must manually distill rule changes from CLAUDE.md into SKILL.md, keeping SKILL.md's voice concise.
- A future reader who assumes they should be identical will be confused. This ADR documents the intent.
- `.cursor/rules` should remain in sync with CLAUDE.md body (they serve the same depth). Currently they are.
- The CLAUDE.md header should be updated to stop implying identity: "Copy changes here first, then manually distill into skills/aposd/SKILL.md."
