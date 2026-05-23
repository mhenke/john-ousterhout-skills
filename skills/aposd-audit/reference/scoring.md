# Scoring Framework — Design Health Score

Scoring framework used by `aposd audit`. This file provides the scoring overview and rating bands; the `skills/aposd-audit/SKILL.md` file contains the exact per-dimension count thresholds.

Audit measures what's objectively countable — fix the count, score goes up. Every dimension is scored by counting concrete, observable constructs, not by making interpretive design judgments.

## Dimensions

Each command evaluates 5 dimensions, scored 0-4 individually, summed to a total of 20.

| # | Dimension | What It Counts |
|---|-----------|----------------|
| 1 | Pass-Through Proliferation | Count of pass-through methods + pass-through variable chains |
| 2 | Information Duplication | Instances of the same knowledge appearing in multiple modules |
| 3 | Interface Documentation | Percentage of public methods with interface comments |
| 4 | Naming Quality | Count of identifiers matching vague name blocklist + convention violations |
| 5 | Exception Discipline | Count of custom exception types + catch-and-rethrow patterns |

## Score Rubric

### Per-Dimension (0-4)

| Score | Meaning |
|-------|---------|
| 4 | Excellent — count is 0 or near-0 in this dimension |
| 3 | Good — 1-2 instances, isolated |
| 2 | Partial — 3-5 instances, needs targeted work |
| 1 | Poor — 6-10 instances across the dimension |
| 0 | Critical — 10+ instances or systemic pattern |

See each dimension's diagnostic scan in the audit skill for the exact count thresholds.

### Total (0-20)

| Score | Rating | Meaning |
|-------|--------|---------|
| 18-20 | Excellent | Minor polish only |
| 14-17 | Good | Address weak dimensions |
| 10-13 | Acceptable | Significant work needed |
| 6-9 | Poor | Major overhaul required |
| 0-5 | Critical | Fundamental redesign needed |

## Tactical Tornado Risk

| Risk | Pattern |
|------|---------|
| **Low** | 0-1 dimensions scored ≤2, no systemic patterns |
| **Medium** | 2-3 dimensions scored ≤2, or 1-2 systemic patterns |
| **High** | 4+ dimensions scored ≤2, or pervasive pass-throughs/leakage |

## Report Format

Each command presents findings as:

```
| # | Dimension | Score | Key Finding | Evidence |
|---|-----------|-------|-------------|----------|
| 1 | Pass-Through Proliferation | ? | Count found | File:line:pattern |
| 2 | Information Duplication | ? | Count found | |
| 3 | Interface Documentation | ? | % documented | |
| 4 | Naming Quality | ? | Count found | |
| 5 | Exception Discipline | ? | Count found | |
| **Total** | | **??/20** | **[Rating band]** |
```

Followed by: Tactical Tornado risk, executive summary, detailed findings by severity (P0-P3), action items.
