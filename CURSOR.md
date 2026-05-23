# Using this repo with Cursor

This project includes a **Cursor project rule** so the Ousterhout-inspired behavioral guidelines apply automatically when you work here.

## In this repository

1. Open the folder in Cursor.
2. The rule [`.cursor/rules/aposd-guidelines.mdc`](.cursor/rules/aposd-guidelines.mdc) is committed with `alwaysApply: true`, so you do not need extra installation steps.
3. In Cursor, you can confirm it under **Settings → Rules** (or the project rules UI), where `aposd-guidelines` should appear.

## Use the same guidelines in another project

**Cursor (recommended):** Copy `.cursor/rules/aposd-guidelines.mdc` into that project's `.cursor/rules/` directory (create the folders if needed). Adjust or merge with existing rules as you like.

**Other tools:** If a stack only supports a root instruction file, copy [`CLAUDE.md`](CLAUDE.md) into that project instead (or merge its contents into your existing instructions).

## Optional: personal Agent Skills

If you want the same content as a reusable skill under `~/.agents/skills` or `~/.claude/skills`, use [`skills/aposd/SKILL.md`](skills/aposd/SKILL.md). You can copy or symlink it into your personal skills directory; use whatever layout you use for other skills. For Codex CLI, install packaged agents into `~/.codex/agents` (or project-local `.codex/agents`) from the `dist/codex/.codex/agents` output.

## Claude Code vs Cursor

- **Claude Code:** Install via `curl` or symlink the `skills/aposd` directory into `~/.claude/skills/`. Per-project use relies on `CLAUDE.md`.
- **Cursor:** Use the committed `.cursor/rules/` file as described above. Cursor does not read `.claude-plugin/` or `CLAUDE.md` by default.

## For contributors

When you change the ten behavioral rules, keep **[`CLAUDE.md`](CLAUDE.md)** and **[`.cursor/rules/aposd-guidelines.mdc`](.cursor/rules/aposd-guidelines.mdc)** in sync. If the published skill/plugin text should match, update **[`skills/aposd/SKILL.md`](skills/aposd/SKILL.md)** as well.
