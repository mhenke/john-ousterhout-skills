# Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Target has 200+ files | Sampling 15 files may miss systemic issues | Sample systematically — first/middle/last per directory group. Document the sample scope. |
| Script dependency fails (`scripts/critique-storage.mjs` not found) | Skill is symlinked without the scripts directory | Skip persistence. Report "Snapshot skipped (scripts not available)". Continue the audit. |
| All dimensions score 0 | Either the codebase is critically broken, or the audit is measuring the wrong thing | Re-check the calibration examples. If the codebase truly has zero pass-throughs, zero duplication, etc., that's a valid audit result. |
| User asks for a code review, not an audit | The two are confused | Audit measures design metrics (countable). Code review finds bugs and style issues. Redirect to the appropriate tool. |
| Snapshot persistence fails | Missing `.aposd/audit/` directory or permissions | Create the directory, or skip persistence and document: "Snapshot skipped (write failed)" |
| Trend shows regression | Score dropped since last run | Check which dimension(s) regressed. Focus fixes on those dimensions first. |
