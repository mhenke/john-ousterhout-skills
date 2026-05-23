# ADR-006: Align Audit and Critique with Impeccable Convention

**Date:** 2026-05-23
**Status:** Accepted
**Applies to:** `skills/aposd-critique/SKILL.md`, `skills/aposd-audit/SKILL.md`

## Context

The `aposd critique` and `aposd audit` commands were originally separated by ADR-001 (critique = qualitative principles evaluation, audit = quantitative metrics). However, the audit's 5 dimensions (Module Design, Information Hiding, Comments, Naming, Error Strategy) were all *design quality judgments*, not *measurable standards*. This meant fixing reported issues didn't reliably change the score — each run made different judgment calls.

Meanwhile, the impeccable skill's tools (sourced from the same superpowers ecosystem) had a proven pattern:

| Tool | Domain | What it measures | Scoring basis |
|------|--------|-----------------|---------------|
| `impeccable critique` | Design evaluation | UX heuristics, AI slop, cognitive load | Nielsen's 10 (0-4 each, /40) |
| `impeccable audit` | Technical conformance | A11y, perf, theming, responsive | Objective standards (WCAG 4.5:1, 44px touch targets) |

The APOSD tools' descriptions used similar language to Impeccable's but the implementations had drifted — particularly the audit, which measured interpretive design quality instead of objective counts.

## Decision

Align `aposd critique` and `aposd audit` with the Impeccable convention:

**Critique** remains a qualitative design evaluation but adopts Impeccable's report structure: Anti-Patterns Verdict (→ Tactical Tornado Verdict) first, then score/assessment table, then findings, then personas, then questions. Two independent assessments (Strategic Thinker + Tactical Tornado) feed into a single synthesized report — no raw output section.

**Audit** becomes a measurement of *objectively countable* design metrics, not interpretive quality judgments:

| Old dimension | Problem | New dimension | What's counted |
|---------------|---------|---------------|----------------|
| Module Design | "Is this module deep?" — subjective | Pass-Through Proliferation | Pass-through methods + variable chains |
| Information Hiding | "Is this leaking?" — subjective | Information Duplication | Same knowledge appearing in multiple modules |
| Comments & Documentation | "Are comments good?" — subjective | Interface Documentation | % of public methods with interface comments |
| Naming & Obviousness | "Is this obvious?" — subjective | Naming Quality | Vague names matching a blocklist |
| Error Strategy | "Is this well-handled?" — subjective | Exception Discipline | Custom exception types defined |

Fix the count → score goes up, every time. Same code produces the same score.

## Rationale

- The Impeccable pattern is proven and ecosystem-native — deviating from it created the drift
- Audit score instability was a direct consequence of measuring interpretive judgments
- Critique was closer to correct but was bloated with redundant process sections
- Aligning both makes the tools predictable for users: fix issues → score improves

## Consequences

- `aposd audit` scores become deterministic for the same code
- `aposd critique` drops the "Raw Assessment Output" section — assessments are synthesized directly into the report
- Both tools use P0-P3 severity (matching Impeccable) instead of Critical/Major/Minor
- `reference/scoring.md` must be updated to reflect the new audit dimensions
- Users familiar with Impeccable will find the same report structure here

## Subsequent Decisions

### Critique Numeric Score

Impeccable critique scores Nielsen's 10 heuristics 0-4 each for a /40 total. Following this pattern, APOSD critique scores the 18 principles 0-2 each (violate=0, at-risk=1, pass=2) for a /36 total.

Rating bands scaled from the /20 convention: 32-36 Excellent, 25-31 Good, 18-24 Acceptable, 11-17 Poor, 0-10 Critical.

This overrides ADR-001's statement that "Critique no longer produces a /20 numeric score." ADR-001's core intent (critique = principles evaluation, audit = metrics) stands — the /36 is a principles-derived score, not a separate metrics framework.

### Sub-Agent Permission Gate

Impeccable critique has a detailed sub-agent gate that asks for user permission, reports degradation state, and handles failure modes. APOSD critique adopts the same pattern: ask once, report degradation with a specific reason string if sub-agents are unavailable, declined, or fail to spawn.

### Suggested Command in Findings (Deferred)

Impeccable critique and audit both include a "Suggested command" field in each priority issue, routing to specific fix commands. APOSD deliberately omits this — the fix commands are domain-specific (impeccable's `polish`, `harden`, etc.) and don't have APOSD equivalents. Instead, findings route to the generic `aposd` skill, and the user selects which principle or dimension area to address. This is tracked as a future improvement if APOSD gains domain-specific fix commands.
