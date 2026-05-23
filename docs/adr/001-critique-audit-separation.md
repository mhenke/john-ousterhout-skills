# ADR-001: Critique-Audit Separation

**Date:** 2026-05-23
**Status:** Accepted
**Applies to:** `skills/aposd-critique/SKILL.md`, `skills/aposd-audit/SKILL.md`

## Context

The project ships two design evaluation commands: `aposd critique` and `aposd audit`. Both were evaluating the same 5 dimensions (Module Design, Information Hiding, Comments & Documentation, Naming & Obviousness, Error Strategy) using the same /20 numeric scoring rubric. The only difference was output format: critique had persona walkthroughs, audit had severity tagging. This made the two tools redundant — users couldn't choose one over the other based on a meaningful distinction.

Compare with impeccable's critique (design heuristics, cognitive load, AI slop) vs audit (accessibility, performance, responsive) — fundamentally different domains.

## Decision

Separate critique and audit into distinct concerns:

**Critique** is a **qualitative principles-based evaluation**. It assesses code against the 17 APOSD design principles (pass/at-risk/violate per principle) and uses two persona perspectives (Strategic Thinker vs Tactical Tornado). No numeric /20 score. No reference to `scoring.md`. The assessment tells you *whether the design philosophy is sound*.

**Audit** is a **quantitative metrics-based evaluation**. It scores the code across 5 dimensions using the /20 rubric from `reference/scoring.md`. It counts red flags, tags severity, and identifies specific locations. The assessment tells you *what specific code problems exist and how severe they are*.

## Rationale

- Users choose by need: "Is the design approach sound?" → critique. "What specific problems exist and how bad are they?" → audit.
- Eliminates redundancy — each tool has a unique purpose.
- Follows impeccable's pattern of domain-based separation rather than format-based separation.
- Principles assessment (17 dimensions) is richer than 5-dimension scoring for design philosophy questions.

## Consequences

- Critique no longer produces a /20 numeric score — users get a per-principle pass/at-risk/violate tally.
- Critiques cannot be compared by numeric score across runs (audit still can).
- Users must know which tool to invoke for their question.
- The `reference/scoring.md` rubric is now audit-only.
