# Routing Rules

The skill responds to three invocation patterns determined by the first word:

| Prefix | Mode | Behavior |
|--------|------|----------|
| *(none)* | Always-on (mode 1) | Apply all 15 rules during any coding task. No explicit invocation needed. |
| `critique` | Critique (mode 2) | Produce a design evaluation — principles assessment with tactical vs strategic diagnosis. Delegates to [aposd-critique](../aposd-critique/SKILL.md). |
| `audit` | Audit (mode 3) | Produce a comprehensive design audit — severity-scored findings with tactical-tornado detection. Delegates to [aposd-audit](../aposd-audit/SKILL.md). |

### Resolution order

1. First word of invocation checked against prefix table
2. If no prefix matches → always-on (mode 1)
3. If prefix matches → delegate to the corresponding sibling skill

### Fallback

If the user says "just make it work" or "quick fix", follow Rule 1 (Strategic Over Tactical) — state the strategic alternative before proceeding tactically. This applies regardless of mode.

### Edge cases

| Input | Resolution |
|-------|------------|
| `aposd critique [empty]` | Falls through to always-on mode |
| `aposd audit [nonexistent]` | Falls through to always-on mode |
| `aposd something-else` | Falls through to always-on mode |
| `just make it work` | Always-on mode with strategic fallback |
