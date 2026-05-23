# ADR-004: APOSD Skill Always-On Triggering

**Date:** 2026-05-23
**Status:** Accepted
**Applies to:** `skills/aposd/SKILL.md`

## Context

The standalone `aposd` skill (containing the 15 APOSD behavioral rules) is meant to be always-on — it should guide every code modification. But its description read like an on-demand diagnostic tool:

> Use when code has shallow modules, information leakage, pass-through methods, vague names, duplicated logic, or other complexity problems. Also use when writing new code...

This triggered only when the user mentioned code smells ("shallow modules") rather than on every coding task. The agent would skip loading the skill during routine implementation work, missing the always-on behavioral rules.

## Decision

Rewrite the description to put "writing any code" first, signaling always-on behavior:

> Use when writing, reviewing, or modifying any code. Also use when code has shallow modules, information leakage, pass-through methods, duplicated logic, vague names, or accumulating design debt from tactical shortcuts.

Following the writing-skills skill's guidelines:
- Description describes **when to use** (triggering conditions), not what the skill does
- No workflow summary (avoids the CSO trap where agents follow the description instead of reading the skill)
- "Writing, reviewing, or modifying any code" covers all coding tasks
- The "Also use when..." clause preserves discoverability for analysis/review use cases

## Rationale

- The 15 behavioral rules should apply to every code modification — this is the skill's purpose
- Per writing-skills skill: description should trigger on the problem, not describe the solution
- The problem the aposd skill solves ("code written without design depth") applies whenever any code is written
- The skills are hardlinked to `.agents/skills/` — no separate deployment step needed

## Consequences

- The skill loads for all coding tasks, consuming more context per session
- At 1333 words, the skill is large for an always-loaded file — may need trimming in future
- Agent will apply the 15 behavioral rules even for trivial changes (which is correct — the rules say "for trivial tasks, use judgment")
