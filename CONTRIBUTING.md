# Contributing

## Project Structure

```
CLAUDE.md                          # Source of truth for 15 behavioral rules
skills/aposd/SKILL.md              # Always-on skill (condensed rules + reference sections)
skills/aposd-critique/SKILL.md     # Design critique command
skills/aposd-audit/SKILL.md        # Design audit command
skills/release-workflow/SKILL.md   # Release process
.cursor/rules/aposd-guidelines.mdc # Cursor mirror (identical to CLAUDE.md body)
docs/adr/                          # Architecture Decision Records
reference/                         # Canonical reference files (principles, personas, red-flags, scoring)
agents/aposd-agent.md              # Agent behavioral profile design artifact
```

## How to...

### Modify a behavioral rule

1. Edit `CLAUDE.md` first — it's the source of truth.
2. Manually distill the change into `skills/aposd/SKILL.md` keeping condensed wording.
3. Mirror the change into `.cursor/rules/aposd-guidelines.mdc` (body should match CLAUDE.md).
4. Update `CHANGELOG.md` for the next release.

### Add a new skill

1. Create `skills/<name>/SKILL.md` with frontmatter.
2. Add the path to `.claude-plugin/plugin.json` `skills` array.
3. Update `.claude-plugin/marketplace.json` keywords/description if applicable.
4. Add reference files to `skills/<name>/references/` if the skill needs them.
5. Document the install path in `README.md`.

### Add a new ADR

1. Create `docs/adr/NNN-short-description.md` following the template in existing ADRs.
2. Use lowercase, hyphenated names. No abbreviations ("skill" not "sk").
3. Include: Context, Decision, Rationale, Consequences sections.

### Cut a release

Follow the release workflow skill: `skills/release-workflow/SKILL.md`.

### Reference files

`reference/` at project root is the canonical location for shared reference files. Skill directories that need them vendored copies under `skills/<name>/references/` for reliable path resolution when symlinked into agent skill directories. Edit the root copy first, then copy into skill directories.
