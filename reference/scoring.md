# Scoring Framework — Design Health Score

Scoring framework used by `aposd audit`. Centralized here to avoid duplication.

## Dimensions

Each command evaluates 5 dimensions, scored 0-4 individually, summed to a total of 20.

| # | Dimension | What It Checks |
|---|-----------|---------------|
| 1 | Module Design | Module depth, interface complexity, abstraction layers, pass-throughs, temporal decomposition |
| 2 | Information Hiding | Leakage, overexposure, interface contamination, general-purpose mixture |
| 3 | Comments & Documentation | Interface comments, comment quality, stale docs, implementation docs in interfaces |
| 4 | Naming & Obviousness | Name precision, code clarity, special cases, consistency |
| 5 | Error Strategy | Error elimination, exception count, error-handling duplication, crash vs recover |

## Score Rubric

### Per-Dimension (0-4)

| Score | Meaning |
|-------|---------|
| 4 | Excellent — no issues in this dimension |
| 3 | Good — minor issues, isolated |
| 2 | Partial — several issues, needs targeted work |
| 1 | Poor — major issues across the dimension |
| 0 | Critical — fundamental problems, redesign needed |

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
| **Low** | Code shows design investment. Deep modules, clear interfaces, good comments. |
| **Medium** | Some areas show quick-and-dirty patterns. Mix of shallow and deep modules. |
| **High** | Pervasive shallow modules, leaky abstractions, pass-through chains, missing comments. Code that "works" but is increasingly difficult to change. |

## Report Format

Each command presents findings as:

```
| # | Dimension | Score | Key Finding |
|---|-----------|-------|-------------|
| 1 | Module Design | ? | [most critical issue or "--"] |
| 2 | Information Hiding | ? | |
| 3 | Comments & Documentation | ? | |
| 4 | Naming & Obviousness | ? | |
| 5 | Error Strategy | ? | |
| **Total** | | **??/20** | **[Rating band]** |
```

Followed by: Tactical Tornado risk, executive summary, detailed findings by severity, action items.
