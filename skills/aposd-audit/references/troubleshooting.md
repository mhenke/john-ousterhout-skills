# Troubleshooting

## Common Problems

| Problem | Cause | Fix |
|---------|-------|-----|
| Target has 200+ files | Sampling 15 files may miss systemic issues | Sample systematically — first/middle/last per directory group. Document the sample scope. |
| Script dependency fails (`scripts/critique-storage.mjs` not found) | Skill is symlinked without the scripts directory | Skip persistence. Report "Snapshot skipped (scripts not available)". Continue the audit. |
| All dimensions score 0 | Either the codebase is critically broken, or the audit is measuring the wrong thing | Re-check the calibration examples. If the codebase truly has zero pass-throughs, zero duplication, etc., that's a valid audit result. |
| User asks for a code review, not an audit | The two are confused | Audit measures design metrics (countable). Code review finds bugs and style issues. Redirect to the appropriate tool. |
| Snapshot persistence fails | Missing `.aposd/audit/` directory or permissions | Create the directory, or skip persistence and document: "Snapshot skipped (write failed)" |
| Trend shows regression | Score dropped since last run | Check which dimension(s) regressed. Focus fixes on those dimensions first. |
| Audit times out on large codebase | Scanning 500+ files sequentially | Increase sample size but stay systematic: first/middle/last of each subdirectory group. Report sample scope explicitly. |
| All findings tagged P0 | Scope creep in severity classification | Re-read: P0 = blocks task completion. If everything blocks, your threshold is too broad. Demote most to P1/P2. |
| Dimension feels inapplicable | Target is very small or homogeneous | Score based on actual count. Zero pass-throughs in 50 lines is valid 4/4. Document "Scored based on actual count of 0." |
| Same finding reported across multiple runs | Snapshot persistence failed silently | Verify `.aposd/audit/` exists and is writable. Run slug command manually to debug. |
| Finding appears in every file | Pattern is systemic, not isolated | Cluster as one systemic pattern with total count, not N scattered findings. |
| Conflicting audit results | Different auditor interpreted rubrics differently | Re-calibrate: both auditors must use the same count thresholds and calibration examples. |

## Recovery Procedures

### Persistence Failure Recovery

If snapshot persistence fails mid-audit:

```bash
# Manually create storage directory
mkdir -p .aposd/audit

# Compute slug manually
APOSD_STORAGE_SUBDIR=audit node scripts/critique-storage.mjs slug "<target>"

# If slug script is unavailable, compute a simple slug:
echo "<target>" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
```

### Partial Audit Recovery

If audit is interrupted mid-way (e.g., timeout on dimension 3 of 5):

1. Document which dimensions were scored: "Scored dimensions 1-2 before interruption."
2. Score remaining dimensions based on what was already gathered.
3. Report partial confidence: "Dimensions 3-5 scored from partial scan — re-run for full accuracy."

### Calibration Drift Recovery

If scores drift up or down over time without code changes:

1. Check the same target produces the same counts on re-run.
2. If counts differ, the audit process is inconsistent — re-read the calibration examples.
3. If counts are consistent but scores differ, the rubric application changed — stick to count thresholds exactly.

## Error Handling Patterns

| Error Pattern | Detection | Recovery |
|-------------|-----------|----------|
| Missing target path | Target argument is empty or doesn't exist | Default to workspace root. Report "Target not specified — auditing workspace root." |
| Unreadable file | Permission denied on source file | Skip file, log: "Skipped <path> (permission denied)". Continue audit. |
| Binary file encountered | Non-text extension or read error | Skip, document: "Skipped <path> (binary)". Do not treat as missing documentation. |
| Generated file detected | In `dist/`, `build/`, `node_modules/`, `__pycache__` | Skip entirely. Report "Excluded <n> generated files." |
| Empty directory | No source files in target path | Report "Target directory is empty — no files to audit." Score all dimensions 4/4 by default. |

## Error Recovery

| Failure Mode | Behavior | Recovery Action |
|-------------|----------|-----------------|
| Script not found (`scripts/critique-storage.mjs`) | Skip persistence, continue audit | Report "Snapshot skipped (scripts not available)". Manual fallback: create `.aposd/audit/<slug>.md` with the report body. |
| Target path doesn't exist | Default to workspace root | Report "Target not found — auditing workspace root instead." |
| Permission denied on source file | Skip file, continue audit | Document "Skipped `<path>` (permission denied)." Include it in sample count. |
| Binary file encountered | Skip silently | Document "Excluded `<n>` binary files." Do not count them as undocumented. |
| Audit interrupted mid-run (timeout) | Partial results | Score only completed dimensions. Report "Audit interrupted — dimensions X-Y scored from partial scan." |
| Trend data unavailable | First run for this slug | Print "First run for this target, no trend yet." |

All failures print an error message and continue. The audit never blocks on non-critical errors.

## Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| Scoring dimensions without evidence | e.g., Pass-Through Proliferation scored 2/4 with no count | Every score must cite the count and file:line:pattern |
| Judging design quality instead of counting | e.g., "This module is shallow" is interpretive, not measurable | Count pass-throughs. Count duplications. Count missing docs. |
| Tagging everything as P0 | e.g., all 5 findings marked P0 dilutes prioritization | P0 = blocks progress, P1 = major fix, P2 = local, P3 = polish |
| Treating audit like a code review | Bug hunting and design evaluation are different | Audit measures design metrics. Don't list typos or style issues. |
| Reporting findings without file:line:pattern | e.g., "Naming violations found" with no locations | Every finding must pass the Specificity Validation Gate |

## Edge Cases

### Single-File Module

A target with one file (under 100 lines):
- Normal audit applies, but sampling is unnecessary
- Expect most dimensions to score 3-4 (small scope limits accumulation of design debt)
- Exception: naming quality and documentation are still fully measurable

### Configuration-Only Directory

A target containing only `.json`, `.yaml`, `.toml` files:
- Interface Documentation: N/A — config files have no methods to document
- Report: "Configuration-only directory. Dimensions 1, 3, 5 scored as N/A. Auditing dimensions 2 and 4 only."
- Score the available dimensions, normalize to /20 proportionally

### Framework Boilerplate

A target with heavy framework-generated code (e.g., Rails scaffold, Spring Boot initializr):
- Flag generated code separately from hand-written code
- Report: "<n> files are framework-generated (not counted in pass-through or duplication metrics)"
- Focus audit on hand-written modules

### Monorepo with Multiple Languages

A target spanning Python, TypeScript, and Go modules:
- Audit each language module separately
- Report per-language scores and a composite
- Calibration examples apply regardless of language — pass-throughs, duplication, and naming are language-agnostic
