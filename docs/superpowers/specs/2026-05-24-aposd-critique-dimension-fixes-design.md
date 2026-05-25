# aposd-critique: PluginEval Dimension Improvements

Improve the 5 PluginEval dimensions scoring C or below for the aposd-critique skill.

## Dimensions

### 1. triggering_accuracy (C → target: B+)

**Changes:**
- Add `keywords` frontmatter: `keywords: [design, critique, aposd, complexity, module, abstraction, tactical, debt]`
- Description already shortened to <200 chars with disambiguation (done in prior round)

### 2. scope_calibration (F → target: B)

**Changes:**
- Add machine-readable scope fields to frontmatter:
  ```yaml
  scope_max_input: 15 files
  scope_max_output: 5 issues
  scope_analysis_depth: qualitative
  ```
- Quantify the "Scope" section prose with explicit numeric limits

### 3. progressive_disclosure (C → target: B)

**Changes:**
- Move Quick Reference table to line 8 (right after intro), before Setup
- Extract 18-principle table from main body into `references/principles.md` (already the canonical reference)
- Replace table with: `See references/principles.md for the full 18-principle framework.`

### 4. robustness (F → target: C)

**Changes:**
- Add pre-check before Setup step 2: probe `node scripts/critique-storage.mjs` is executable
- Defensive fallbacks already exist for missing targets, slug failures, and ignore.md

### 5. code_template_quality (F → target: pass/false positive)

**Changes:** None. All code blocks already have `bash`/`python` language tags. Score is an eval tool limitation, not a skill defect.

## Files affected

- `SKILL.md` — frontmatter, Quick Reference position, Scope section, 18-principle table removal, script pre-check
- `references/principles.md` — confirm 18 principles are fully documented (already is — no changes needed)
