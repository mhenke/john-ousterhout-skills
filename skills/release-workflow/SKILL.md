---
name: release-workflow
description: Use when starting a release, drafting a changelog, creating git tags, publishing GitHub releases, or updating README install examples to pin to the latest tagged version.
license: MIT
---

# Release Workflow

## Overview

Standardized release process for this project: draft CHANGELOG.md → git tag → GitHub release → update README install examples.

## Setup

Before starting, verify:
- Working tree is clean (`git status`)
- All changes for this release are committed on `main`
- The remote origin is accessible (`git fetch`)

## Process

### 1. Draft CHANGELOG Entry

Read `CHANGELOG.md` at project root to find the current latest version. Then read the git log since the last tag:

```bash
git log --oneline <last-tag>..HEAD
# If no prior tag:
git log --oneline --all
```

Categorize commits by type:
- **Added** — new features (`feat:`, `feat(...):`)
- **Changed** — changes in existing functionality (`refactor:`, `perf:`)
- **Fixed** — bug fixes (`fix:`, `fix(...):`)
- **Docs** — documentation (`docs:`, `docs(...):`)

Update `CHANGELOG.md` following [Keep a Changelog](https://keepachangelog.com/) format. Add a new section at the top for this release with the planned version number and date.

### 2. Create Git Tag

```bash
git tag -a v<major>.<minor>.<patch> -m "Release v<major>.<minor>.<patch>"
git push origin v<major>.<minor>.<patch>
```

Semantic versioning:
- **Major** (1.0.0): Breaking changes to behavioral rules, SKILL.md structure, or plugin compatibility
- **Minor** (0.1.0): New rules, new commands, new ADRs
- **Patch** (0.0.1): Bug fixes, documentation updates, non-breaking refactors

### 3. Create GitHub Release

```bash
gh release create v<major>.<minor>.<patch> \
  --title "v<major>.<minor>.<patch>" \
  --notes "See CHANGELOG.md for details."
```

### 4. Update README Install Examples

Search README.md for raw.githubusercontent.com URLs pointing to `main` branch:

```
raw.githubusercontent.com/mhenke/john-ousterhout-skills/main/
```

Replace `main` with the new tag name:

```
raw.githubusercontent.com/mhenke/john-ousterhout-skills/v<major>.<minor>.<patch>/
```

The `/plugin install` commands use the plugin registry and don't need URL changes.

### 5. Commit the Release

```bash
git add CHANGELOG.md README.md
git commit -m "chore: release v<major>.<minor>.<patch>"
git push origin main
```

## Version Contract

Releases signal the level of change users should expect:

- Tagged releases are stable snapshots with a documented CHANGELOG
- `main` branch is the development edge — may contain unreleased changes
- Users pinning to a tag get stability; users on `main` get latest
- There is no formal SemVer guarantee until v1.0.0 — the 0.x range acknowledges the project is evolving rapidly
