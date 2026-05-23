# APOSD Critique & Audit — Precision Anchoring

**Date:** 2026-05-23
**Status:** Accepted (updated for ADR-001 critique-audit separation)
**Applies to:** `skills/aposd-critique/SKILL.md`, `skills/aposd-audit/SKILL.md`, `skills/aposd/SKILL.md`

## Overview

Critique and audit produced inconsistent scores and vague findings when re-run on the same target. The root cause was a lack of **evidence anchoring**: each run evaluated holistically without pinning scores to specific rubric criteria and code locations. Additionally, critique and audit were redundant — both evaluated the same 5 dimensions with the same /20 scoring.

**Two parallel decisions:**

1. **Precision anchoring:** Make each evaluation deterministic by anchoring every score/finding to cited rubric criteria (audit) or principles (critique) and quoted code evidence. No state files, no delta tracking, no persistence.
2. **Critique-audit separation (ADR-001):** Critique evaluates design philosophy qualitatively (18 principles, pass/at-risk/violate, persona analysis). Audit evaluates code quality quantitatively (5 dimensions, /20 numeric score, red flag counts). Different domains, different outputs.

**Inspiration:** Impeccable's critique (design review) vs audit (technical quality) — fundamentally different domains, not just different formats.

## Changes to Both Skills

The following changes apply to both `aposd-critique` and `aposd-audit` with tool-specific adaptations noted:

### 1. Resolution Anchoring

Replace freeform evaluation with evidence-anchored scoring/assessment:

**Audit:** Before scoring, read `reference/scoring.md` for the rubric. For each dimension, identify the rubric criterion and find specific code evidence (file:line:pattern) that demonstrates it.

**Critique:** Before assessing each principle, find specific code evidence that supports the pass/at-risk/violate judgment. (Critique does not reference `scoring.md` — it uses `reference/principles.md`.)

**Scope scoping:** If the target has more than 15 files, sample systematically (first/middle/last of each directory group). Report the sample scope.

### 2. Specificity Validation Gate

Before any finding is reported, it must pass this checklist:

```
□ File path (absolute or relative to target)
□ Line number(s)
□ Code pattern (exact snippet, 1-3 lines)
□ Complexity symptom (change amplification / cognitive load / unknown unknowns)
□ Concrete fix (an action — "extract into UserRepository.find()" not "consider refactoring")
□ Affected concept: for critique — which of the 18 principles; for audit — which of the 5 dimensions
```

### 3. Finding-to-Concept Mapping

**Audit:** Tag every finding with the score dimension it affects (Module Design, Information Hiding, etc.). Users see: fix this → that dimension score improves.

**Critique:** Tag every finding with the principle it relates to (Deep Modules, Information Hiding, etc.). Users see: fix this → that principle assessment improves.

### 4. Skill Routing

Replace self-fixing instructions with:

```
> To fix using APOSD design principles, load the `aposd` skill.
> It applies the 10 APOSD behavioral rules during implementation.
> Address findings in the priority order above.
```

### 5. Score Calibration Note (audit only)

Add to the audit's Executive Summary:

```
Note: Scores are based on evidence found at the reported locations.
If the same code is re-run without changes, the same evidence produces
the same score. Fix the findings to change the score.
```

## Critique-Specific Changes

- **Role redefined:** Principles-only qualitative assessment. No numeric /20 score, no `scoring.md` reference.
- **Setup:** Resolution anchoring references principles, not rubric criteria.
- **Assessment A:** Evidence requirement per principle citation (file:line reason, not just PASS/FAIL).
- **Assessment B:** Location requirement per red flag (exact file:line, not generic description).
- **Design Health Score table:** Removed entirely — belongs to audit.
- **Priority Issues:** Tag findings by principle (not dimension).
- **Specificity Validation Gate:** References "principle affected" (not "dimension").
- **Common Mistakes:** Added "Reporting findings without file:line:pattern" row. Updated "Scoring without evidence" to "Assessing without evidence."

## Audit-Specific Changes

- **Role redefined:** Quantitative metrics-based assessment. /20 numeric score, red flag counts, severity tagging.
- **Design Health Score table:** Expanded from 4 columns to 5 (added Evidence column).
- **Tactical Tornado Risk:** Now requires count evidence (e.g., "HIGH — 7 red flags: 2 information leakage, 3 shallow modules, 2 pass-throughs").
- **Score Calibration Note:** Added to Executive Summary.

## Reference Changes

### `reference/scoring.md`

No changes needed. The rubric was already well-defined — the issue was that skills weren't requiring citation of the rubric criteria.

## Related Decisions

- ADR-001: Critique-audit separation (principles vs metrics)
- ADR-002: Precision anchoring and specificity enforcement
- ADR-003: Skill routing for fix implementation
- ADR-004: APOSD skill always-on triggering (description fix)

## Files Changed

| File | Change |
|------|--------|
| `skills/aposd-critique/SKILL.md` | Redefined as principles-only. Added resolution anchoring, specificity validation gate, finding-to-principle mapping, evidence/location requirements in assessments, skill routing. Removed /20 Design Health Score table. Updated dimension→principle throughout. |
| `skills/aposd-audit/SKILL.md` | Added resolution anchoring, specificity validation gate, 5-column score table with evidence, count-based tactical tornado risk, skill routing, score calibration note. |
| `skills/aposd/SKILL.md` | Fixed description for always-on triggering: "Use when writing, reviewing, or modifying any code." |

## Success Criteria

- Running `aposd critique` twice on unchanged code produces the same principle assessments and findings
- Running `aposd audit` twice on unchanged code produces the same /20 score and findings
- Every finding includes file path, line number, code pattern, complexity symptom, and concrete fix
- No finding uses phrases like "some functions" or "consider exploring"
- After fixing a reported finding, re-running shows the changed evidence pattern
- The report ends with routing to the `aposd` skill, not an offer to self-fix
- Critique and audit ask different questions (design philosophy vs code quality metrics)
