# Security Policy

## Overview

This project contains behavioral instructions for AI coding agents. The files in this repository directly govern agent behavior — changes to them can affect how an agent operates.

## Scope

The following files are considered security-critical because they govern AI agent behavior:

- `CLAUDE.md` — Root behavioral rules, loaded automatically by Claude Code
- `skills/*/SKILL.md` — Skill files loaded on-demand by AI coding agents
- `.cursor/rules/*.mdc` — Cursor project rules
- `agents/*.md` — Agent behavioral profiles

## Reporting a Vulnerability

If you discover a security issue — such as prompt injection vectors, unsafe default behaviors, or malicious instructions embedded in skill files — please open an issue with the label `security` rather than filing a public PR.

Do not submit a public PR for security-critical changes without first reporting the issue. This gives maintainers a chance to assess the impact and coordinate a fix.

## Safe Use Guidelines

For consumers of this project:

- **Pin to tagged releases** rather than `main` branch for production use. Tags are reviewed snapshots; `main` receives unreviewed changes.
- **Review changes** when updating versions. The CHANGELOG.md documents what changed between releases.
- **Treat SKILL.md and CLAUDE.md as executable code.** These files run as instructions in your AI agent — apply the same trust and review process you would for a binary or script.

## Branch Protection

This repository requires pull request reviews for changes to `main`. All changes to SKILL.md, CLAUDE.md, and `.cursor/rules/*.mdc` should be reviewed with attention to:

1. Does the change introduce instructions that override agent safety boundaries?
2. Does the change reference external resources that could be compromised?
3. Does the change modify the project's behavioral rules in a way that affects downstream users?
