---
name: create-release-workflow
description: Use when creating a new release — drafting a changelog entry, creating git tags, publishing via GitHub Releases, or updating README install examples to pin to the latest tagged version.
license: MIT
---

# Release Workflow

## Overview

Standardized release process: draft CHANGELOG entry → git tag → GitHub release → update README → commit.

## Version Prompting

Before starting the process, determine the next version:

```bash
git describe --tags --abbrev=0
```

This prints the latest tag (e.g., `v0.1.0`). Decide the bump type:

- **Major** (1.0.0): Breaking behavioral rules, SKILL.md structure, or plugin compatibility
- **Minor** (0.2.0): New rules, commands, or ADRs
- **Patch** (0.1.1): Bug fixes, docs, non-breaking refactors

No prior tag? Start at `v0.1.0`.

## Setup

Before starting:
- `git status` — working tree must be clean
- `git log origin/main..HEAD` — no unpushed commits
- `git fetch` — remote accessible

## Process

### 1. Draft CHANGELOG Entry

Read `CHANGELOG.md` to find the current latest version. Read the git log since the last tag:

```bash
git log --oneline $(git describe --tags --abbrev=0)..HEAD
# If no prior tag:
git log --oneline --all
```

Categorize commits: **Added** (`feat:`), **Changed** (`refactor:`, `perf:`), **Fixed** (`fix:`), **Docs** (`docs:`). Update `CHANGELOG.md` following [Keep a Changelog](https://keepachangelog.com/) format.

### 2. Create Git Tag

```bash
git tag -a v{NEW_VERSION} -m "Release v{NEW_VERSION}"
git push origin v{NEW_VERSION}
```

### 3. Create GitHub Release

Extract the current version's entry from `CHANGELOG.md` and use it as the release body:

```bash
# Extract changelog section for this version
python3 << 'PYEOF' > /tmp/changelog-entry.md
import sys
with open('CHANGELOG.md') as f:
    content = f.read()
version = 'v{NEW_VERSION}'
start = content.find(f'## [{version}]')
if start == -1:
    print(f"Error: no CHANGELOG entry for {version}", file=sys.stderr)
    sys.exit(1)
end = content.find('\n## [', start + 1)
if end == -1:
    end = content.find('\n[Unreleased]:', start)
    if end == -1:
        end = len(content)
print(content[start:end].strip())
PYEOF

gh release create v{NEW_VERSION} \
  --title "v{NEW_VERSION}" \
  --notes-file /tmp/changelog-entry.md
```

### 4. Update README Install Examples

Search README.md for `raw.githubusercontent.com/mhenke/john-ousterhout-skills/` followed by a version reference. Replace with the new version tag. The `/plugin install` commands don't need URL changes.

### 5. Commit

```bash
git add CHANGELOG.md README.md
git commit -m "chore: release v{NEW_VERSION}"
git push origin main
```

## Troubleshooting

| Step | Failure | Fix |
|------|---------|-----|
| 2. Tag push | `git push origin v{NEW_VERSION}` fails (tag exists) | Tag may already exist remotely. Run `git tag -d v{NEW_VERSION}` locally, then re-push. Or bump to next patch version. |
| 3. Release creation | `gh release create` or changelog extraction fails | GitHub CLI not authenticated? Run `gh auth status`. Changelog extraction failed? Verify the version heading in CHANGELOG.md matches `v{NEW_VERSION}` exactly. Or create the release manually at the GitHub URL. |
| 4. README update | No `main` reference found in README | The install examples may already point to a tag. Update them to the new tag directly. |
| 5. Push rejected | Remote has new commits | `git pull --rebase origin main`, resolve conflicts, re-push. Re-do steps 1-4 if CHANGELOG or README conflicts. |

## Version Contract

- Tagged releases are stable snapshots with a documented CHANGELOG
- The `main` branch is the development edge — may contain unreleased changes
- Users pinning to a tag get stability; users on `main` get the latest
- No formal SemVer guarantee until v1.0.0 — 0.x range acknowledges rapid evolution

## Related

- [Keep a Changelog](https://keepachangelog.com/) — changelog format reference
- `references/version-examples.md` — version bump examples
