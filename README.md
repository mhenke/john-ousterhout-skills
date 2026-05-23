# A Philosophy of Software Design-Inspired Guide

Behavioral guidelines for AI coding agents inspired by [*A Philosophy of Software Design, 2nd Edition*](https://www.amazon.com/Philosophy-Software-Design-2nd/dp/173210221X) by John Ousterhout (Yaknyam Press, 2021).

Designed for Claude Code, Cursor, OpenCode, Antigravity, and any AI coding agent.

## The Problem

Software complexity is the fundamental challenge in writing programs. As systems grow, complexity accumulates and makes code harder to understand, modify, and extend. Most programmers focus on getting code working quickly ("tactical programming") without investing in design quality, which accelerates the accumulation of complexity.

> "The greatest limitation in writing software is our ability to understand the systems we are creating."

Ousterhout identifies three symptoms of complexity:

| Symptom | Description |
|---------|-------------|
| **Change amplification** | A single change requires edits in many places |
| **Cognitive load** | How much a developer must hold in their head to make a change |
| **Unknown unknowns** | You don't know what code to change or what to consider |

Every principle and red flag in this skill traces to one of these three.

## The Solution

Ten behavioral rules in one `CLAUDE.md` file that make agents design software strategically, not tactically:

| Rule | Addresses |
|------|-----------|
| **Strategic Over Tactical** | Design debt, "just make it work" pressure |
| **Design Deep Modules** | Shallow interfaces, classitis |
| **Information Hiding** | Leaky abstractions, exposed internals |
| **Pull Complexity Downward** | Complex callers, simple implementations |
| **Comments First** | Missing or useless documentation |
| **Design for Reading** | Obscure code, bad naming |
| **Define Errors Out of Existence** | Error-handling duplication |
| **Better Together or Better Apart** | Wrong module boundaries |
| **Design It Twice** | First-design bias |
| **Modify Strategically** | Code rot during maintenance |

Plus two on-demand analysis commands:

| Command | Purpose |
|---------|---------|
| `aposd critique [module, class, or subsystem]` | Evaluate design against principles + tactical assessment |
| `aposd audit [target]` | Comprehensive audit with severity scoring + tornado detection |

## Install

**Option A: CLAUDE.md (per-project, quick start)**

The 10 behavioral rules in a single file. No command skills or reference docs.

New project:
```bash
curl -o CLAUDE.md https://raw.githubusercontent.com/mhenke/john-ousterhout-skills/main/CLAUDE.md
```

Existing project (append):
```bash
echo "" >> CLAUDE.md
curl https://raw.githubusercontent.com/mhenke/john-ousterhout-skills/main/CLAUDE.md >> CLAUDE.md
```

**Option B: Claude Code Plugin**

From within Claude Code, add the marketplace and install:
```
/plugin marketplace add mhenke/john-ousterhout-skills
/plugin install john-ousterhout-skills@aposd-skills
```

This installs the main skill and all command skills.

**Option C: Full Install (all skills + reference docs)**

Clone the repo and symlink into your agent's skill directories:

```bash
git clone https://github.com/mhenke/john-ousterhout-skills.git
cd john-ousterhout-skills

# OpenCode
ln -s $(pwd)/skills/aposd ~/.agents/skills/aposd

ln -s $(pwd)/skills/aposd-critique ~/.agents/skills/aposd-critique
ln -s $(pwd)/skills/aposd-audit ~/.agents/skills/aposd-audit

# Claude Code
ln -s $(pwd)/skills/aposd ~/.claude/skills/aposd
ln -s $(pwd)/skills/aposd-critique ~/.claude/skills/aposd-critique
ln -s $(pwd)/skills/aposd-audit ~/.claude/skills/aposd-audit

# Antigravity CLI
ln -s $(pwd)/skills/aposd ~/.antigravity/skills/aposd
ln -s $(pwd)/skills/aposd-critique ~/.antigravity/skills/aposd-critique
ln -s $(pwd)/skills/aposd-audit ~/.antigravity/skills/aposd-audit
```

**Option D: Cursor**

Copy `.cursor/rules/aposd-guidelines.mdc` into your project's `.cursor/rules/` directory. See [CURSOR.md](CURSOR.md).

**Option E: Codex CLI**

Copy packaged skills/agents from `dist`:

```bash
# Project-local
cp -r dist/agents/.agents your-project/
mkdir -p your-project/.codex
cp -r dist/codex/.codex/agents your-project/.codex/

# Or user-wide
mkdir -p ~/.agents/skills
cp -r dist/agents/.agents/skills/* ~/.agents/skills/
mkdir -p ~/.codex
cp -r dist/codex/.codex/agents ~/.codex/
```

## How to Know It's Working

These guidelines are working if you see:

- **Fewer pass-through chains and shallow classes** — Modules have simple interfaces and substantial implementations
- **Comments written before code** — Interface documentation precedes implementation
- **Errors eliminated, not handled** — Interfaces designed so common errors can't happen
- **Design discussed before implementation** — "Design it twice" becomes a natural habit
- **Cleaner diffs during maintenance** — Code improves with each modification instead of accumulating debt

## Key Insight

From Ousterhout:

> "The overall goal is to reduce complexity; this is more important than any particular principle or idea you read here."

When principles conflict, the one that better reduces cognitive load wins. Every red flag traces to one of the three complexity symptoms. If a principle isn't reducing complexity, don't apply it dogmatically.

## Customization

These guidelines are designed to be merged with project-specific instructions. Add them to your existing `CLAUDE.md` or create a new one.

For project-specific rules, add sections like:

```markdown
## Project-Specific Guidelines

- Use TypeScript strict mode
- All API endpoints must have tests
- Maximum method length: 40 lines
```

## Tradeoff Note

These guidelines bias toward **strategic design over tactical speed**. For trivial tasks (simple typo fixes, obvious one-liners), use judgment — not every change needs full strategic rigor.

The goal is reducing costly design debt on non-trivial work, not slowing down simple tasks.

## License

MIT

## Inspiration

This project was inspired by [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) — the CLAUDE.md format, command skill structure, and README/EXAMPLES/CURSOR pattern are adapted from that project. The audit and critique command patterns were inspired by [impeccable](https://github.com/pbakaus/impeccable).
