# Changelog

All notable changes to this project are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

- Initial release setup (CHANGELOG, tags, release workflow)

## [v0.1.0] — 2026-05-24

### Added

- 15 APOSD behavioral rules (Strategic Over Tactical, Deep Modules, Information Hiding, General-Purpose Modules, Different Layer Different Abstraction, Pull Complexity Downward, Comments First, Choosing Names, Design for Reading, Define Errors Out of Existence, Better Together or Better Apart, Design It Twice, Design for the Future, Increments Are Abstractions, Modify Strategically)
- `aposd critique` command — qualitative principles-based design evaluation with two persona perspectives (Strategic Thinker vs Tactical Tornado)
- `aposd audit` command — quantitative metrics-based design audit with severity scoring
- Precision Anchoring — every score point must cite rubric criteria and specific code evidence
- Specificity Validation Gate — 6-field checklist before any finding is reported
- Resolution Anchoring — findings tagged with affected dimension/principle
- Skill Routing — critique/audit reports route to `aposd` skill for fix implementation
- Always-on triggering — description updated so skill loads for all coding tasks
- Hard Invariants — upfront non-negotiable rules for critique runs
- ignore.md mechanism — suppress previously-acknowledged findings
- Run Notes — per-run status documentation in critique output
- Persist Snapshot — audit score snapshots for trend tracking
- CLI-agnostic symlink install pattern — OpenCode, Claude Code, Antigravity, Codex CLI
- Cursor support — `.cursor/rules/aposd-guidelines.mdc`

### Changed

- Separated critique (qualitative) from audit (quantitative) — eliminated redundant evaluation
- Audit dimensions replaced interpretive judgments with objectively countable metrics
- Report structure aligned to Impeccable convention — Anti-Patterns Verdict → Assessment Table → Priority Issues → Personas → Questions
- Critique score changed from weighted /36 to simple pass-count /18
- Condensed SKILL.md for always-on context efficiency
- Reference files vendored into skill directories for reliable resolution

### Fixed

- Stale "10 rules" counts updated to 15
- Plugin manifest descriptions and ID alignment
- ADR naming and numbering inconsistencies
- Documentation gaps, heading drift, and cross-file synchronization
- Storage path resolution — files persist relative to repo root, not cwd
- Agent file scope examples for clarity
- Removed accidental self-referencing symlinks

### Docs

- Architecture Decision Records (ADR-001 through ADR-007) documenting every design decision
- Comprehensive EXAMPLES.md with usage patterns per principle
- CURSOR.md for Cursor-specific setup
- Full reference files (principles, personas, red-flags, scoring)
- CODE_OF_CONDUCT.md, CONTRIBUTING.md, SECURITY.md
- MIT License

[Unreleased]: https://github.com/mhenke/john-ousterhout-skills/compare/v0.1.0...HEAD
[v0.1.0]: https://github.com/mhenke/john-ousterhout-skills/releases/tag/v0.1.0
