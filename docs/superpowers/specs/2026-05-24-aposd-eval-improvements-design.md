# aposd Skill: PluginEval Score Improvement

**Date:** 2026-05-24
**Status:** Draft

## Goal

Improve the aposd skill's PluginEval scores on three dimensions:
- **Orchestration Fitness** (0.795 → target B+/A-)
- **Scope Calibration** (0.550 → target C+)
- **Robustness** (0.000 → target D+/C-)

These were the three lowest-scoring weighted dimensions in the full evaluation at
`72.01/100 (Silver)`. The three fixes applied in the prior pass (description trim,
troubleshooting inline, code templates) addressed lower-weight dimensions. This spec
targets the remaining drag.

## Changes

### 1. Orchestration Fitness — Reframe Routing Rules as Invocation Modes

**Problem:** The `## Routing Rules` section uses orchestrator language ("load the
corresponding skill file and follow its instructions"). PluginEval penalizes supervisor
logic inside worker skills.

**Fix:** Rename `## Routing Rules` to `## Invocation Modes`. Replace dispatch language
with output-description language:

```markdown
## Invocation Modes

The skill responds to three invocation patterns:

1. **No prefix**: Apply all 15 rules as always-on behavior during coding tasks.
2. **Prefix `critique`**: Produce a design evaluation — principles assessment + tactical
   vs strategic diagnosis.
3. **Prefix `audit`**: Produce a comprehensive design audit — severity-scored findings
   with tactical-tornado detection.

Each mode is triggered by the first word of the invocation:
- No command word → always-on (mode 1)
- `aposd critique [target]` → critique output (mode 2)
- `aposd audit [target]` → audit output (mode 3)
```

### 2. Scope Calibration — Add Explicit Scope Section

**Problem:** No explicit boundary documentation. The blend is dragged down by a 0.0
static contribution (PluginEval has no `scope_calibration` sub-check). The judge scored
it 0.85 but the ceiling under standard depth is 0.647.

**Fix:** Add a `## Scope` section after Input/Output that states what's in scope, what's
deliberately out of scope, and the boundary with sibling skills (aposd-critique,
aposd-audit).

### 3. Robustness — Fallback Statement + Expanded Troubleshooting

**Problem:** No documented fallback behavior when the skill cannot complete its task.
The Troubleshooting section (moved inline in prior pass) meets the "at least 3 failure
modes" rubric but doesn't state the default fallback.

**Fix:**
- Update `## Input / Output` to document graceful fallback: "if the task is trivial or
  out of scope, the skill remains silent and normal agent behavior proceeds without
  APOSD guidance."
- Add 2 rows to the Troubleshooting table for ambiguous input and non-design tasks.

## Interaction Effects

- **Description truncation** (prior pass) resolves the MISSING_TRIGGER anti-pattern
- **Troubleshooting inline + code templates** (prior pass) already fixed structural
  completeness and code template quality
- These three changes are independent and can be applied in one atomic edit pass

## Verification

After applying all changes, run:
```bash
plugin-eval score /home/mhenke/.agents/skills/aposd --output json
```

Expected outcomes:
- Orchestration Fitness → ≥ 0.83 (judge rewards worker framing)
- Scope Calibration → ≥ 0.60 (judge sees explicit boundary; static still 0.0)
- Robustness → ≥ 0.40 (judge sees fallback + troubleshooting)
- Overall composite → ≥ 74 (up from 72)
