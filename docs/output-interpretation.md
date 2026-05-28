# Interpreting `aposd critique` and `aposd audit` Output

Both commands produce structured output with specific terminology. This doc explains what it all means.

---

## Invocation Modes

The `aposd` skill has three modes:

| Invocation | Mode | What Happens |
|------------|------|-------------|
| *(any coding task)* | Always-on | Applies 15 behavioral rules during coding. No explicit command needed. |
| `aposd critique [target]` | Critique | Delegates to the `aposd-critique` skill — design evaluation with dual-persona assessment |
| `aposd audit [target]` | Audit | Delegates to the `aposd-audit` skill — countable design metrics with severity scoring |

**Always-on mode triggers on:** writing code, reviewing code, refactoring, debugging, designing modules, naming, error handling, abstraction layering.

**Always-on mode stays silent for:** trivial one-line fixes (typo, rename, config change), mechanical refactors with no design impact, exploratory/provisional code, low-level debugging, performance profiling, framework-specific patterns, CI/CD, security auditing.

**No explicit invocation is needed** for everyday coding — the agent applies the rules automatically. You'll see it in how the agent structures code: deeper modules, simpler interfaces, fewer error cases for callers.

### Strategic Fallback

If you say "just make it work" or "quick fix," the agent will:
1. State the strategic alternative (what a deeper redesign would look like)
2. Document the tradeoff
3. Then proceed tactically

This is deliberate — the tradeoff is recorded so you know what design debt you're accepting.

### Routing Edge Cases

| If you type... | It resolves to... |
|---------------|-------------------|
| `aposd critique [empty]` | Always-on mode (no target, no critique) |
| `aposd audit [nonexistent]` | Always-on mode (target doesn't exist) |
| `aposd something-else` | Always-on mode (unknown prefix) |

---

## Design Principles: 18 in Critique vs 15 in CLAUDE.md

The `aposd critique` command evaluates **18 design principles**. The always-on behavioral rules in `CLAUDE.md` list **15**. Here's why:

| Category | Principles | Source |
|----------|-----------|--------|
| Shared (15) | Strategic Over Tactical, Deep Modules, Information Hiding, General-Purpose Modules, Different Layer Different Abstraction, Pull Complexity Downward, Comments First, Choosing Names, Design for Reading (Code Should Be Obvious), Define Errors Out of Existence, Better Together or Better Apart, Design It Twice, Design for the Future, Increments Are Abstractions, Modify Strategically | Both |
| Extra in critique (3) | **Consistency** — Use consistent conventions for naming, patterns, behavior. Reduces cognitive load. | `skills/aposd-critique/references/principles.md#15` |
| | **Performance as Design** — Module boundaries and data structures have more performance impact than micro-optimizations. Never sacrifice design clarity for speculative performance. | `skills/aposd-critique/references/principles.md#18` |
| | **Comments Describe Non-Obvious** — Comments should describe what isn't obvious from the code (rationale, cross-module decisions). Split from "Comments First" in the critique framework. | `skills/aposd-critique/references/principles.md#11-12` |

**What to expect:** A critique will show "X/18 pass." Don't worry about the mismatch — the always-on rules guide *implementation* (15 is sufficient for daily work), while the broader set is for *evaluation*.

---

## Personas: Tactical Tornado & Strategic Thinker

Critique and audit both use two opposing personas to evaluate code:

### Tactical Tornado (The Fast Shipper)

- **Motto:** "Working code is enough."
- **Looks for:** pass-through chains, information leakage, god classes, shallow modules, missing comments, vague names, error handling that mirrors the happy path
- **Risk levels:** Low / Medium / High based on red flag counts
- **Detection patterns:** Code that works today but is harder to change tomorrow

### Strategic Thinker (The Architect)

- **Motto:** "Working code isn't enough."
- **Looks for:** deep modules, simple interfaces, errors defined out of existence, interface comments first, obvious code
- **Recommendations:** The single most impactful design improvement

**Critique runs both independently.** Assessment A (Strategic Thinker) and Assessment B (Tactical Tornado Detection) are isolated from each other. Neither sees the other's output until synthesis. If sub-agents are unavailable, they run sequentially and the limitation is reported.

Full persona definitions: `skills/aposd-critique/references/personas.md`

---

## Severity Levels: P0–P3

Both critique and audit tag findings by severity:

| Level | Label | Meaning |
|-------|-------|---------|
| **P0** | Blocking | Prevents task completion. Fix immediately. |
| **P1** | Major | Significant complexity increase. Fix before next milestone. |
| **P2** | Minor | Notable but local. Fix when in the area. |
| **P3** | Polish | Worth fixing, no urgency. |

A good report has **few or no P3 issues** — too many low-severity items creates noise. Both commands prefer a small number of high-signal findings.

---

## Audit Scoring Rubric: /20

The `aposd audit` command scores 5 dimensions, each 0–4, summed to /20.

### Dimensions

| # | Dimension | What It Counts |
|---|-----------|----------------|
| 1 | Pass-Through Proliferation | Pass-through methods + pass-through variable chains |
| 2 | Information Duplication | Same knowledge appearing in multiple modules |
| 3 | Interface Documentation | % of public methods with interface comments |
| 4 | Naming Quality | Count of vague names (blocklist) + convention violations |
| 5 | Exception Discipline | Custom exception types + catch-and-rethrow patterns |

### Per-Dimension Score (0–4)

| Score | Meaning |
|-------|---------|
| 4 | Excellent |
| 3 | Good — 1-2 instances, isolated |
| 2 | Partial — 3-5 instances, needs work |
| 1 | Poor — 6-10 instances |
| 0 | Critical — 10+ or systemic |

### Total Score Rating

| Score | Rating | What It Means |
|-------|--------|---------------|
| 18-20 | Excellent | Minor polish only |
| 14-17 | Good | Address weak dimensions |
| 10-13 | Acceptable | Significant work needed |
| 6-9 | Poor | Major overhaul required |
| 0-5 | Critical | Fundamental redesign needed |

### Tactical Tornado Risk

| Risk | Pattern |
|------|---------|
| **Low** | 0-1 dimensions scored ≤2, no systemic patterns |
| **Medium** | 2-3 dimensions scored ≤2, or 1-2 systemic patterns |
| **High** | 4+ dimensions scored ≤2, or pervasive pass-throughs/leakage |

Full scoring details: `skills/aposd/references/scoring.md`

---

## Snapshot Persistence

Both commands save results to `.aposd/`:

| Command | Directory | File Format |
|---------|-----------|-------------|
| `critique` | `.aposd/critique/` | `<timestamp>__<slug>.md` |
| `audit` | `.aposd/audit/` | `<timestamp>__<slug>.md` |

Each snapshot has YAML frontmatter:

```yaml
target: "src/services/UserService.java"
total_score: 12
p0_count: 0
p1_count: 2
p2_count: 3
p3_count: 1
timestamp: "2026-05-25T01-21-08Z"
slug: "src-services-UserService-java"
```

The slug is derived from the resolved file path. Different path spellings (`src/Foo` vs `./src/Foo`) produce different slugs and break trend continuity.

Critique snapshots exclude: "Ask the User," "Recommended Actions," "Common Mistakes," "Red Flags" sections, and the trend line.

### ignore.md

Suppress recurring findings in `.aposd/critique/ignore.md`:

```
src/services/user-service.js:42
src/services/order-service.js:87-92
```

One `file:line` or `file:start-end` per line. Findings matching these locations are dropped silently in future critiques.

---

## Agent Behavior During Analysis

- **Dual-assessment isolation:** Two independent evaluations run without cross-contamination. If sub-agents aren't available, the limitation is noted.
- **Specificity Validation Gate:** Every finding must have file path, line numbers, code pattern, complexity symptom, concrete fix, and affected principle. Missing any field → finding is discarded.
- **Large targets (>50 files):** Sub-agents are used to parallelize scanning across directory groups.
- **Degradation guarantee:** If the skill can't complete (script missing, timeout, target not found), it exits silently with no side effects. No partial or misleading output.

---

## Troubleshooting

Common situations and what to expect from each command.

### Critique-specific

| What You See | Likely Cause | Recovery |
|-------------|--------------|----------|
| "Snapshot skipped (scripts not available)" | `scripts/critique-storage.mjs` not found — skill symlinked without scripts directory | Critique itself is still valid. Only snapshot persistence is skipped. |
| "degraded (sequential)" | Sub-agents unavailable for dual assessment | Assessments run one after another instead of in parallel. Results are still valid but may have bias from cross-contamination. |
| Snapshot skipped, no trend | Slug computation failed (vague or root-level target) | Try a more specific target path. Persistence needs a resolvable file path. |
| "Target not found or empty" | Path does not exist or file has no content | Check the path. No findings to evaluate. |
| "Target is generated code" | Only protobuf/generated files in target | No design decisions to evaluate. Critique skipped. |
| "Target too small for meaningful critique" | Single file under 50 lines | Not enough design surface. Critique exits or runs at reduced depth. |
| Mixed-language files reported | Target spans JS + SQL + YAML etc. | Critique scopes to the primary language by line count. The scoping decision is reported. |

### Audit-specific

| What You See | Likely Cause | Recovery |
|-------------|--------------|----------|
| All dimensions score 0 | Codebase may be critically broken, *or* audit is measuring the wrong thing | Re-check the calibration examples. Genuinely clean code scoring 0 across all dimensions is a valid result. |
| All findings tagged P0 | Severity classification scope creep | P0 = blocks progress. If everything blocks, threshold is too broad. Most should be P1/P2. |
| "Scored dimensions 1-2 before interruption" | Audit timed out mid-run | Remaining dimensions scored from partial data. Re-run for full accuracy. Report is partial confidence. |
| "Target not specified — auditing workspace root" | No target path given | Defaults to workspace root. If that's unintended, re-run with an explicit path. |
| "Skipped <path> (binary)" | Binary files in target | Skipped silently. Not counted as missing documentation. |
| "Excluded <n> generated files" | `dist/`, `build/`, `node_modules/`, etc. detected | Generated files excluded from all dimensions. |
| "Target directory is empty" | No source files | All dimensions score 4/4 by default. |
| Config-only directory | Only `.json`, `.yaml`, `.toml` files | Dimensions 1, 3, 5 scored N/A. Remaining dimensions normalized proportionally. |

### Both Commands

| What You See | Likely Cause | Recovery |
|-------------|--------------|----------|
| "200+ files" reported | Large scan area | Sub-agents parallelize across directory groups. Total files scanned is reported. |
| User asks for the wrong command | Critique vs audit confusion | Critique = qualitative design philosophy. Audit = countable metrics. Redirect to the correct command. |
| Finding appears in every file | Systemic pattern, not isolated | Should be clustered as one pattern with total count, not N scattered findings. |
| Temp file cleanup failure notice | Agent interrupted during persistence | Small temp file residue possible. Not harmful. |
| Two assessments contradict each other | Different personas see different problems | Expected and deliberate — the report synthesizes both. Note where they agree and diverge. |
| Scores change without code changes | Calibration drift in audit | Re-run the same target. If counts are consistent but scores differ, rubric application drifted — stick to count thresholds exactly. |

### Edge Cases

| Target Type | How Commands Handle It |
|-------------|----------------------|
| **Single file (<100 lines)** | Normal analysis applies. Expect most dimensions to score 3-4 (small scope limits debt accumulation). Naming and documentation still fully measurable. |
| **Framework boilerplate** | Generated code flagged separately from hand-written. Audit focuses on custom modules. |
| **Monorepo, multiple languages** | Each language module audited separately. Per-language scores plus composite. Pass-through, duplication, and naming are language-agnostic. |
| **One-off script (<50 lines)** | Critique: may exit with "too small." Audit: design patterns haven't had time to accumulate. |

### Common Mistakes Interpreting Output

| Mistake | Why It's Wrong | What to Look For Instead |
|---------|---------------|--------------------------|
| Reading critique like a score | Critique is qualitative — X/18 pass count is directional, not exact | Read the findings, not just the number. Priority issues matter more than the pass count. |
| Ignoring the "no rubber-stamps" rule | A critique with all 18 PASS but no code evidence is invalid | Every verdict must cite file:line:pattern. If it doesn't, the finding was discarded. |
| Treating every P0 as equally urgent | P0 means different things per context | Look at the complexity symptom (change amplification / cognitive load / unknown unknowns) to understand impact. |
| Expecting audit scores to improve immediately | Audit measures *countable constructs* — fix counts, scores go up | Fix the pass-throughs, add documentation, eliminate duplication. Re-run to see the score improve. |

### Red Flags in Output

Some patterns in the output itself signal that something went wrong:

- A critique or audit with **zero findings** across all dimensions — either the target is trivially clean, or the analysis failed silently
- **Every finding tagged P0** — severity inflation, no real prioritization
- Findings without **file:line:pattern** — specificity gate was bypassed. The finding may not be verifiable.
- **Only generic recommendations** ("consider refactoring") — should be concrete actions ("extract into UserRepository.find()")

---

## Scripts, Templates, and Other Files

The project contains utility files users may encounter or want to use directly.

### Scripts

`skills/aposd-critique/scripts/critique-storage.mjs` handles snapshot persistence for critique (and audit uses a copy at `skills/aposd-audit/scripts/critique-storage.mjs`). CLI:

| Command | Purpose |
|---------|---------|
| `node critque-storage.mjs slug <path>` | Compute a slug from a resolved file path |
| `node critque-storage.mjs write <slug> <body-file>` | Write snapshot to `.aposd/critique/` |
| `node critque-storage.mjs latest <slug>` | Read most recent snapshot frontmatter |
| `node critque-storage.mjs trend <slug> [limit]` | Read last N frontmatter entries |

Slugs are truncated to 50 characters. They derive from `path.relative(cwd, abs)`, falling back to `basename(abs)` if the path is outside cwd.

`skills/aposd-audit/scripts/audit-report-template.md` — Copy-paste-ready report template with `?` placeholders for programmatic or manual audit use.

### Templates

`skills/aposd/templates/` contains copy-paste-ready code for common APOSD patterns:

| File | Pattern |
|------|---------|
| `deep-module.py` | Deep module template (Rule 2 + 6) — simple interface, complex implementation |
| `error-suppressor.py` | Error elimination template (Rule 10) — define errors out of existence |
| `manifest.json` | Plugin manifest (JSON) |
| `manifest.toml` | Plugin manifest (TOML) |

### Examples

`skills/aposd-audit/examples/` contains operational examples:

| File | What It Demonstrates |
|------|---------------------|
| `full-audit-workflow.sh` | Complete audit pipeline: run → compute slug → persist → read trend |
| `example-audit-report.md` | Filled-in audit report with real findings and severity classifications |

The root `EXAMPLES.md` (932 lines) gives principle-by-principle code examples showing tactical (wrong) vs strategic (right) approaches with explanations.

### Environment Variables

`APOSD_CRITIQUE_META` — JSON metadata passed to the snapshot write command:

```json
{
  "target": "src/services/UserService.java",
  "total_score": 12,
  "p0_count": 0,
  "p1_count": 2,
  "p2_count": 3,
  "p3_count": 1
}
```

Used by both critique and audit for snapshot metadata. Set automatically during analysis — users shouldn't need to set it directly, but it's visible in scripts and workflow examples.

### Temp File Workflow

During snapshot persistence, the agent:
1. Writes the snapshot body to a temp file
2. Passes the temp file path to `critique-storage.mjs write`
3. Deletes the temp file after the write (even on failure)

If deletion fails, a brief notice appears in output. Temp file residue is possible if the agent is interrupted mid-write.

### File Relationships and Notes

| Note | Detail |
|------|--------|
| **Two copies of principles.md** | Identical in `skills/aposd/references/` and `skills/aposd-critique/references/`. The copy in `references/` (critique) is the authoritative version. Changes must be applied to both. |
| **CLAUDE.md vs SKILL.md** | `CLAUDE.md` is the source of truth for the 15 behavioral rules. `skills/aposd/SKILL.md` is a condensed version. See `docs/adr/005-claude-sk-condensation.md` for the rationale. |
| **EXAMPLES.md paths** | The "Related docs" line references `reference/principles.md` etc. These are relative links within the project root that **do not exist** — the actual files are at `skills/aposd/references/` and `skills/aposd-critique/references/`. |

---

## Reference Files

| File | What It Covers |
|------|----------------|
| `skills/aposd/references/principles.md` | Full 18 principles with examples and "taking it too far" limits |
| `skills/aposd/references/scoring.md` | Audit scoring rubric and rating bands |
| `skills/aposd/references/troubleshooting.md` | Failure modes and recovery for the main skill |
| `skills/aposd-critique/references/personas.md` | Tactical Tornado & Strategic Thinker definitions |
| `skills/aposd-critique/references/red-flags.md` | 15 red flags in priority order with detection and fix guidance |
| `skills/aposd-critique/references/troubleshooting.md` | 12 critique-specific failure scenarios |
| `skills/aposd-audit/references/troubleshooting.md` | Audit-specific recovery procedures |
| `skills/aposd/templates/` | Copy-paste-ready code templates (deep module, error suppression) |
| `skills/aposd-audit/examples/` | Audit workflow script and example report |
| `EXAMPLES.md` | Principle-by-principle code examples (tactical vs strategic) |
