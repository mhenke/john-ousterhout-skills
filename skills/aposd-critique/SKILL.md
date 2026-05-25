---
name: aposd-critique
description: Use proactively when evaluating whether code follows APOSD design principles — unexpected complexity, hard-to-follow control flow, or modules that feel shallow. Use for a second opinion on quality, or when suspecting tactical shortcuts. Not for baselining refactoring — use aposd-audit for countable evidence.
keywords: [design, critique, aposd, complexity, module, abstraction, tactical, debt, proactive, review]
scope_max_input: 15 files
scope_max_output: 5 issues
scope_analysis_depth: qualitative
license: MIT
---

# aposd critique — Design Critique

Principles-based design evaluation from *A Philosophy of Software Design, 2nd Edition* (Ousterhout, 2021). Combines two independent assessments into a single report with persona walkthroughs. Follows the impeccable critique convention.

**Usage:** `aposd critique [module, class, or subsystem]`

## Quick Reference

| Question | Look At |
|----------|---------|
| Is the design approach sound? | Design Principles Score (pass count) |
| What's the single biggest problem? | Priority Issues (top P0) |
| Would a different designer see it differently? | Persona Walkthroughs section |
| Is it getting better over time? | Trend line from persisted snapshots |

## Setup

1. **Resolve the target** to a concrete file path or module name. If the target does not exist or is empty, report "Target not found or empty" and exit the critique (no findings to evaluate). If the target has more than 15 files, sample systematically (first/middle/last of each directory group). Report the sample scope: "Sampled 8/24 files in src/services/."

**Pre-check:** Verify `scripts/critique-storage.mjs` is available. If not found, set `persist=false` and skip all persistence steps. Continue the critique without snapshots.

2. **Compute the slug** for persistence and trend tracking:
   ```bash
   node scripts/critique-storage.mjs slug "<resolved-path>"
   ```
   Keep it. If the command exits non-zero, skip persistence and trend for this run, but continue the critique.

3. **Read `.aposd/critique/ignore.md`** if it exists. Drop matching findings silently; it is the only prior-run input critique consumes.

## Input / Output

- **Input** — A module, class, or subsystem path. Defaults to current directory if omitted. Targets with >15 files are sampled.
- **Output** — Combined critique report: Tactical Tornado Verdict, Design Principles Score (X/18 pass), Priority Issues with P0-P3 severity, Persona Walkthroughs. Persisted to `.aposd/critique/` for trend tracking.

## When Not to Use

- For counting measurable metrics — use `aposd audit` instead
- For bug hunting or style nitpicks — critique evaluates design philosophy, not correctness
- For trivial files (<50 lines) with no design decisions — the output won't justify the process

## Scope

**Analyzes:** One module, class, or subsystem at a time (max 15 files sampled). Evaluates design decisions — module boundaries, interface quality, error handling, abstraction layers, naming, and comments. No more than 5 priority issues per critique.

**Does not analyze:** Cross-module consistency, runtime performance, test coverage, security vulnerabilities, or style formatting. These are outside the critique's design philosophy lens.

**Output:** A combined report with persona perspectives. Not a score — critique is qualitative. For a measurable score, use `aposd audit`.

## Depth rules

- Treat the review as two independent attempts to explain the code, then synthesize the answers.
- Do not stop at naming a smell; connect it to change amplification, cognitive load, or unknown unknowns.
- For every major issue, identify the root abstraction leak or boundary mistake, not just the symptom.
- Compare at least two possible redesigns before recommending one.
- Prefer a small number of high-signal findings over a long list of shallow observations.

## Hard Invariants

- Assessment A (Strategic Thinker Review) and Assessment B (Tactical Tornado Detection) are both required.
- Assessment A must finish before Assessment B findings enter the parent synthesis context.
- If sub-agents are unavailable, run sequentially: finish and record A first, then run B, then synthesize. Report `Assessment independence: degraded (sub-agents unavailable)`.
- A skipped assessment B is a failed critique run unless the codebase is empty.
- The chat response is the primary deliverable. The persisted snapshot is only an archive/backlog for later use.
- Every finding must pass the Specificity Validation Gate.

## Gather Assessments

Launch two independent assessments. **Neither may see the other's output.** If sub-agents are unavailable, run sequentially and report the limitation in the report.

#### Assessment A: Strategic Thinker Review

Evaluate the code as the Strategic Thinker persona would. Assess each of the 18 design principles as pass / at risk / violate, with cited code evidence (file:line:pattern). See `references/principles.md` for the full framework.

**Evidence requirement:** Every assessment must include file:line:code evidence. "Strategic Over Tactical: PASS — UserRepository (l12) extracts db logic into a module, reducing change amplification." Not just "PASS."

```python
# Good evidence:
"Deep Modules: VIOLATE — UserService.get_user (user_service.py:42-45) body is:
    return self.repo.find_by_id(user_id)
    # ^^ pass-through method, adds no abstraction, interface == implementation"

# Bad evidence (fails gate):
"Deep Modules: VIOLATE — some methods are shallow"
```

Return: per-principle assessment table, structural analysis (module depth, abstraction layers, interface quality, error strategy), what's working (2-3 items), priority issues (3-5 with what/why/fix), single most impactful design change.

#### Assessment B: Tactical Tornado Detection

Evaluate the code as the Tactical Tornado persona would produce it. Scan for red flags in priority order:

1. **Information Leakage** — same knowledge in multiple places
2. **Shallow Module** — interface as complex as implementation
3. **Temporal Decomposition** — code mirrors execution order
4. **Pass-Through Method** — methods that add no value
5. **Pass-Through Variables** — context threaded unused
6. **Repetition** — duplicated nontrivial code
7. **Special-General Mixture** — general code with special-case logic
8. **Conjoined Methods** — can't understand one without the other
9. **Overexposure** — API forces learning rare features
10-15. Comment, naming, and obviousness red flags

**Location requirement:** Every finding must include exact file path and line numbers. "Information Leakage (HIGH): SQL query string in UserService.findActive (l42) duplicates the same JOIN logic in OrderService.findByUser (l87)." Not "SQL queries are duplicated in service classes."

Return: red flags found (ordered by severity, with file:line:pattern), tactical tornado risk (low/medium/high), count of flags found.

### Generate Combined Critique Report

Synthesize both assessments into a single report. Do not concatenate — weave findings together, noting where both assessments agree, where the Strategic Thinker found strengths the Tactical Tornado scan missed, and where the Tactical Tornado caught issues the Strategic Thinker overlooked. The chat response is the primary deliverable.

#### Tactical Tornado Verdict

**Start here.** Does this code look like it was written tactically? Summarize the Tactical Tornado detection findings: flag counts, file locations, and the most damning pattern found. Note any additional patterns the detection found that the Strategic Thinker missed.

#### Design Principles Score

Present the 18 principles as a table with pass/at-risk/violate per principle:

| # | Principle | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | Strategic Over Tactical | pass / at-risk / violate | File:line:pattern |
| ... | | | |

**Summary: X pass, Y at risk, Z violate (X/18 pass).** The pass count is the health indicator — higher is better. Track it over time via critique snapshots.

#### Overall Impression

Brief gut reaction: what works, what doesn't, the single biggest opportunity for reducing complexity.

#### What's Working

Highlight 2-3 things done well. Be specific about why they reduce complexity (change amplification, cognitive load, unknown unknowns).

#### Priority Issues

The 3-5 most impactful design problems, ordered by importance. Every issue must pass the Specificity Validation Gate:

- **[P0/P1/P2/P3] Issue name**
- **Principle**: Which of the 18 principles this relates to
- **Complexity symptom**: Change amplification / Cognitive load / Unknown unknowns
- **Why it matters**: How this hurts future development
- **Fix**: Concrete action (not "consider refactoring")

Severity: **P0**=blocks progress, **P1**=major complexity increase, **P2**=notable but local, **P3**=polish.

#### Persona Walkthrough

Walk through each persona explicitly with specific code references:

**Tactical Tornado walkthrough:** "If the Tactical Tornado wrote this code, they would let the wrapper grow its own policy language and edge-case heuristics, which increases drift risk." Name the exact function, line, and pattern that would accumulate debt.

**Strategic Thinker walkthrough:** "If the Strategic Thinker were to redesign this, they would keep the wrapper thin, with one clean reference back to the core abstraction and minimal local interpretation." Name the specific redesign.

#### Minor Observations

Quick notes on smaller issues worth addressing. No specificity gate required for these.

#### Questions to Consider

Provocative questions that might unlock better designs:
- "What if this module's interface were designed for the caller, not the implementation?"
- "Could this error case be eliminated by changing the interface contract?"
- "Would merging these two classes produce a deeper module?"

#### Run Notes

Keep this compact. Include status for target slug, ignore list, assessment independence (sub-agents used or sequential), and temp-file cleanup. Run Notes are final-chat only — do not include this section in the persisted snapshot body.

### Worked Example — UserService.java

Given a target at `src/services/UserService.java`, the critique report would look like:

> **Tactical Tornado Verdict:** Medium risk. UserService has 3 pass-through methods (findById→repository.findById, findAll→repository.findAll, deleteById→repository.deleteById) and a mixed abstraction layer where validation and persistence are entangled.
>
> **Design Principles Score: 12/18 pass** (4 at-risk, 2 violate)
>
> | # | Principle | Verdict | Evidence |
> |---|---|---|---|
> | 2 | Deep Modules | at-risk | `findById` body is `return repo.findById(id)` — shallow |
> | 5 | Different Layer | violate | `UserService.createUser` calls validation then repo in same method |
> | 7 | Better Together | at-risk | `UserValidator` and `UserRepository` could merge into deeper module |
> | ... | | | |
>
> **Priority Issues:**
> - **P1** Pass-through chain in UserService (findById→findAll→deleteById) adds no abstraction value
> - **P2** Validation logic in createUser leaks persistence concerns into the service layer
>
> This is illustrative. Your output will follow this structure but reflect the actual target.

### Persist Snapshot

Write the critique report to `.aposd/critique/` so the user can refer back, and so future critiques can show trends. The slug was computed during Setup.

Skip this step if the Setup slug was null (vague or root-level target).

1. **Compute trend score** as the pass count (X/18) from the Design Principles Score.

2. **Write snapshot**: Write the full report body (Design Principles Score through Run Notes) to a temp file, then pass it through the helper with structured metadata. Exclude the "Ask the User" / "Recommended Actions" / "Common Mistakes" / "Red Flags" sections and the snapshot trend line itself from the body:

   The metadata JSON follows this schema:
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

   ```bash
   APOSD_CRITIQUE_META='{"target":"<user phrasing>","total_score":<X>,"p0_count":<n>,"p1_count":<n>,"p2_count":<n>,"p3_count":<n>}' \
     node scripts/critique-storage.mjs write <slug> <body-file>
   ```
   The helper prints the absolute path it wrote. Delete the temp file afterward.

3. **Read trend** for context:
   ```bash
   node scripts/critique-storage.mjs trend <slug> 5
   ```
   This returns a JSON array of the last 5 frontmatter entries (including the one just written).

4. **Append a single line** to the user-visible output, after the report and before the questions:

   > **Trend for `<slug>` (last 5 runs): 72 → 78 → 83 → 81 → 89**
   > Wrote `.aposd/critique/<filename>`.

   If this is the first run for the slug: "First run for this target, no trend yet."

This is fire-and-forget. Do not show the user the helper's JSON output; only the human-readable trend line and the written path. Failures here should not block the rest of the flow; print the error and move on.

### Specificity Validation Gate

Before reporting any non-minor finding, self-validate:

```
□ File path (absolute or relative to target)
□ Line number(s)
□ Code pattern (exact snippet, 1-3 lines)
□ Complexity symptom (change amplification / cognitive load / unknown unknowns)
□ Concrete fix (an action — "extract into UserRepository.find()" not "consider refactoring")
□ Principle affected (which of the 18 design principles this relates to)
```

Missing any field → finding is discarded.

**No rubber-stamps.** "All 18 principles PASS" with no code evidence per principle is not a valid critique. Every verdict must cite file:line:pattern. If you catch yourself writing a finding without evidence, stop and return to the gate check.

**Stop-and-return.** If you find yourself writing a finding without a file:line:pattern, do not continue. Stop. Restart the validation gate for that finding. A finding that doesn't pass is worse than no finding — it wastes the reader's time.

**Passing example:**
```
□ File path: src/services/user-service.js
□ Line number(s): 42-48
□ Code pattern: SQL query string "SELECT * FROM orders WHERE user_id = ?" built inline
□ Complexity symptom: Change amplification (schema change requires updating every query)
□ Concrete fix: Extract into OrderRepository.findByUserId(userId)
□ Principle affected: Deep Modules (interface exposes SQL, caller must know schema)
```

### Ask the User

After presenting findings, ask 1-2 targeted questions based on what was found:

1. **Priority direction**: "I found problems with [principle area A], [B], and [C]. Which should we tackle first?"
2. **Scope**: "I found N issues. Want to address everything, or focus on the top 3?"

### Recommended Actions

After receiving the user's answers, present a prioritized action summary. Every action must pass the Specificity Validation Gate:

1. **[P0/P1/P2/P3]**: Brief description with file:line:pattern
2. ...

Order by the user's stated priorities first, then by impact.

After presenting, tell the user:

> To fix using APOSD design principles, load the `aposd` skill. It applies the 15 APOSD behavioral rules during implementation. Address findings in the priority order above.
>
> Re-run `aposd critique` after fixes to see your assessment improve.

### Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Script dependency fails (`scripts/critique-storage.mjs` not found) | Skill is symlinked without the scripts directory | Skip persistence. Report "Snapshot skipped (scripts not available)". Continue the critique. |
| Sub-agents unavailable for dual assessment | Environment doesn't support sub-agents | Run sequentially: complete Assessment A first, then Assessment B, then synthesize. Report "degraded (sequential)". |
| Slug computation fails (non-zero exit) | Target is vague or root-level | Skip persistence and trend. Continue the critique without snapshot. |
| Target has 200+ files | Sampling 15 files may miss systemic issues | Sample systematically — first/middle/last per directory group. Document the sample scope. |
| Target is missing or empty | Path does not exist or file has no content | Report "Target not found or empty" and exit. No findings to evaluate. |
| User asks for audit, not critique | The two are confused | Critique evaluates design philosophy (qualitative). Audit measures countable metrics (quantitative). Redirect to the appropriate command. |
| Target contains only generated/protobuf files | No design decisions to evaluate | Report "Target is generated code — critique skipped" and exit. |
| Target is a single trivial file (<50 lines) | Not enough design decisions to evaluate | Report "Target too small for meaningful critique" and exit, or evaluate at reduced depth. |
| Target has mixed-language files (e.g., JS + SQL + YAML) | Cross-language analysis exceeds scope | Scope critique to the primary language files (by line count). Report the scoping decision. |
| Assessment takes too long (>5 min) | Large dependency graph or deep nesting | Sample more aggressively. Report the sample scope and that depth was limited. |

### Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| Running assessments sequentially in one head | Second output biased by the first | Use sub-agents. If unavailable, note the bias in the report. |
| Listing red flags without complexity impact | Reader doesn't know WHY it matters | Tag each finding: change amplification / cognitive load / unknown unknowns. |
| Generic persona descriptions | e.g., "Tactical Tornado writes shallow code" adds nothing | Name the specific function, line, and pattern. |
| Assessing principles without evidence | e.g., PASS on rule 2 with no code citation is useless | Every assessment must cite file:line:code. |
| Reporting findings without file:line:pattern | e.g., "Information Hiding violated" with no location | Every finding must pass the Specificity Validation Gate. |

### Red Flags — STOP and Start Over

- Reporting a finding without file:line:pattern
- Assessing a principle without citing code evidence
- Combining assessments without isolation
- Describing a persona generically instead of citing specific code
- Tagging a finding without a complexity symptom
- Reporting more than 5 priority issues
- Using vague language like "consider refactoring" instead of concrete actions

## Related

- [aposd](skills/aposd/SKILL.md) — Always-on behavioral rules
- [aposd-audit](skills/aposd-audit/SKILL.md) — Design audit command
- [references/](references/) — Extended troubleshooting
