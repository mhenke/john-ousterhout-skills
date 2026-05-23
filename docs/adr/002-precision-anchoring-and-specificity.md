# ADR-002: Precision Anchoring and Specificity Enforcement

**Date:** 2026-05-23
**Status:** Accepted
**Applies to:** `skills/aposd-critique/SKILL.md`, `skills/aposd-audit/SKILL.md`

## Context

Running `aposd critique` or `aposd audit` on the same code twice produced different scores and different findings. Scores fluctuated because each AI evaluation was a fresh holistic impression rather than an evidence-anchored assessment. Findings were too vague ("some functions need better names") for users to act on.

The root cause was not lack of persistence/state tracking — it was lack of **evidence anchoring**. Each score was a gut feeling, not a citation of rubric criteria and code locations.

## Decision

Replace freeform evaluation with evidence-anchored evaluation using two mechanisms:

### 1. Resolution Anchoring

Every score point must cite:
- The rubric criterion from `reference/scoring.md` that justifies the score (audit) / the principle evidence (critique)
- Specific code evidence: file path, line number, code pattern

This makes scores reproducible — two runs on the same code see the same evidence and produce the same score.

### 2. Specificity Validation Gate

Before any finding is reported, it must pass a 6-field checklist:
- File path, line numbers, code pattern, complexity symptom, concrete fix, principle/dimension affected

Findings missing any field are discarded. This eliminates vague or unactionable findings.

### 3. Finding-to-Dimension/Principle Mapping

Every finding is tagged with the score dimension (audit) or principle (critique) it affects. Users can see: fix this → that score improves.

## Rationale

- No persistence needed — each run is independent and self-validating
- Follows impeccable's pattern: deterministic output through rigid structure, not state tracking
- Concrete findings are actionable without follow-up questions
- Score transparency (citing rubric + evidence) builds trust even when the score is low

## Consequences

- Increased specificity of all output — no more "some functions" or "consider exploring"
- Slightly more verbose reports (evidence column in score tables)
- Findings are longer but more actionable
- The validation gate may reject borderline findings (desired behavior — quality over quantity)
