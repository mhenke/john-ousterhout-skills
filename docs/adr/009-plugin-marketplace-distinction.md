# ADR-009: Plugin vs Marketplace Manifest Distinction

**Date:** 2026-05-24
**Status:** Accepted
**Applies to:** `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`

## Context

The project ships two JSON manifests in `.claude-plugin/`:

- **`plugin.json`** — The standard Claude Code plugin manifest. Lists skills via relative paths. Consumed by `/plugin install` to resolve skill locations at install time.
- **`marketplace.json`** — The marketplace registry listing. Contains `owner`, `id`, `category`, and wraps the plugin in a `plugins` array with a `source` reference. Consumed by `/plugin marketplace add` for discovery.

Both contain overlapping metadata (name, description, version). Both must be updated when adding a new skill. A naive reader or automated review might flag this as redundancy.

## Decision

Both files are required and serve different harnesses in the Claude Code plugin distribution system. They are not redundant — they are complementary layers:

| Concern | `plugin.json` | `marketplace.json` |
|---------|---------------|---------------------|
| Install-time resolution | Primary | Secondary (via `source: "./"`) |
| Marketplace discovery | Not used | Primary |
| Owner attribution | Simple `author.name` | Full `owner.name` |
| Category | Not present | `workflow` |
| Skill paths | Listed explicitly | Referenced via `source: "./"` |

## Rationale

- The Claude Code plugin system requires both files for full distribution: `plugin.json` for the install mechanism, `marketplace.json` for the discovery mechanism.
- Removing either would break either `/plugin install` or `/plugin marketplace add`.
- The metadata overlap (description, version) is inherent to the platform's two-file convention — it exists in every Claude Code plugin.
- A maintainer adding a new skill must update both files, but this is a property of the platform, not a project design flaw.

## Consequences

- Both files remain in `.claude-plugin/`.
- A maintainer adding a skill must update `plugin.json`'s `skills` array AND `marketplace.json`'s plugin `keywords`/`description` if they differ.
- No tooling to sync the two files — manual update is the convention, matching ADR-005's decision against sync tooling.
