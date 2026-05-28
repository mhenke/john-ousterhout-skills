# Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| Script dependency fails (`scripts/critique-storage.mjs` not found) | Skill is symlinked without the scripts directory | Skip persistence. Report "Snapshot skipped (scripts not available)". Continue the critique. |
| Sub-agents unavailable for dual assessment | Environment doesn't support sub-agents | Run sequentially: complete Assessment A first, then Assessment B, then synthesize. Report "degraded (sequential)". |
| Slug computation fails (non-zero exit) | Target is vague or root-level | Skip persistence and trend. Continue the critique without snapshot. |
| Target has 200+ files | Large scan area | Use sub-agents to parallelize across directory groups. Report total files scanned. |
| User asks for audit, not critique | The two are confused | Critique evaluates design philosophy (qualitative). Audit measures countable metrics (quantitative). Redirect to the appropriate command. |
| Assessment A and B contradict each other | Different personas see different problems | This is expected — the critique synthesizes both perspectives. Note where they agree and where they diverge. |
| Snapshot persistence fails | Missing `.aposd/critique/` directory or permissions | Create the directory, or skip persistence and document: "Snapshot skipped (write failed)" |
