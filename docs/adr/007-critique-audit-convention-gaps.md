# ADR-007: Close Critique and Audit Convention Gaps

**Date:** 2026-05-23
**Status:** Accepted
**Applies to:** `skills/aposd-critique/SKILL.md`, `skills/aposd-audit/SKILL.md`, `scripts/critique-storage.mjs`

## Context

ADR-006 aligned the APOSD critique and audit report structures with the Impeccable convention, but a systematic comparison revealed several gaps that weren't addressed:

| Gap | Affects | Severity | Notes |
|-----|---------|----------|-------|
| Hard Invariants | Critique | High | No upfront rules about what's mandatory |
| ignore.md mechanism | Critique | High | No way to suppress previously-acknowledged findings |
| Run Notes | Critique | Medium | No failure accounting per run |
| Reference path resolution | Both | High | `reference/principles.md` referenced from SKILL.md resolves to skill dir, not project root |
| Audit persistence | Audit | Medium | No snapshot/trend tracking for scores |
| Sub-agent gate | Critique | — | Rejected by ADR-006 (no anchoring bias in APOSD's dual-LLM assessments) |
| Suggested command in findings | Both | — | Deferred by ADR-006 (no APOSD fix commands yet) |
| Skill file duplication | Both | — | Symlinked — not actually duplicated |

Two of the gaps (sub-agent gate, suggested command) were already addressed in ADR-006 as Rejected and Deferred. The remaining six needed resolution.

## Decision

### 1. Hard Invariants (Critique)

Add an upfront **Hard Invariants** section after Setup listing non-negotiable rules:

- Both assessments are required
- Assessment A must finish before B enters synthesis context
- Sequential fallback reports `degraded` status
- Skipped Assessment B = failed run (unless empty codebase)
- Chat response is primary deliverable; snapshot is archive
- Every finding must pass the Specificity Validation Gate

This mirrors Impeccable critique's Hard Invariants but adapted for APOSD's domain (code design vs UI design).

### 2. ignore.md Mechanism (Critique)

Add an ignore-file step to Setup: read `.aposd/critique/ignore.md` if it exists and silently drop matching findings. This is the only prior-run input the critique consumes — all other findings are fresh each run.

This mirrors Impeccable critique's ignore.md convention.

### 3. Run Notes (Critique)

Add a Run Notes section after Questions to Consider, documenting per-run status (slug, ignore list, assessment independence, temp-file cleanup). Run Notes are final-chat-only and excluded from the persisted snapshot.

This mirrors Impeccable critique's Run Notes convention without the Codex-specific infrastructure details.

### 4. Reference Path Resolution (Both)

Copy the reference files (`principles.md`, `personas.md`, `red-flags.md`, `scoring.md`) from the project root `reference/` directory into the skill directories at `skills/aposd-critique/reference/` and `skills/aposd-audit/reference/`. This ensures the relative path references in SKILL.md (e.g., `See reference/principles.md`) resolve correctly when the skill is loaded, regardless of the runtime working directory.

### 5. Audit Persistence (Audit)

Add a **Persist Snapshot** section to the audit SKILL.md, mirroring the critique's pattern but writing to `.aposd/audit/` instead of `.aposd/critique/`. The existing `critique-storage.mjs` script was extended with an `APOSD_STORAGE_SUBDIR` environment variable to support both directories from a single codebase.

### 6. Slug Computation Moved to Setup (Critique)

The slug was previously computed inside the Persist Snapshot section. It's now computed in Setup (before assessments) so it's available throughout the run, matching Impeccable's flow.

## Rationale

- **Consistency**: Users familiar with Impeccable's pattern find the same structure here
- **Determinism**: Hard Invariants prevent skipped assessments; ignore.md prevents stale findings from polluting new runs
- **Accountability**: Run Notes document what happened in a run, aiding debugging
- **Correctness**: Reference files must resolve reliably — depending on a project-root convention is fragile
- **Trend tracking**: Audit scores need trend tracking for the same reason critique scores do — users need to see improvement over time
- **Simplicity**: Single storage script with env-var override avoids code duplication

## Consequences

- Critique gains three new sections: Hard Invariants, ignore.md (in Setup), Run Notes
- Audit gains a Persist Snapshot section
- The storage script now uses `APOSD_STORAGE_SUBDIR` env var (defaults to `critique`) instead of a hardcoded directory name
- Reference files are now vendored inside each skill directory
- slug computation now happens at Setup time rather than at Persist time

## Related Decisions

- ADR-006: Align audit and critique with impeccable convention (established the alignment direction)
- ADR-006 Rejected: Sub-agent gate (no anchoring bias in dual-LLM assessments)
- ADR-006 Deferred: Suggested command in findings (no APOSD fix commands yet)
