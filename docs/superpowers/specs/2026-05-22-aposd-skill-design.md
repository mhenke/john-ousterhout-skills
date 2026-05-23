# APOSD Skill + Agent Design

**Date:** 2026-05-22
**Status:** Superseded — see `2026-05-23-aposd-critique-audit-precision.md` for current spec, `docs/adr/` for current decisions.
**Source:** A Philosophy of Software Design, 2nd Edition (Ousterhout, 2021)

> **Note:** This spec predates ADR-001 (critique-audit separation) and references a removed `aposd-review` command. The review command was eliminated during refactoring — critique absorbed its red flag scanning role. References to 18 principles, 16 red flags, and 1-5 scoring are outdated; the current system uses 18 principles (critique), 15 red flags, and /20 numeric scoring (audit).

## Overview

A portable skill and agent that teaches agents Ousterhout's software design philosophy. Agents load the skill to evaluate code through the complexity lens, write APOSD-compliant code, and identify design problems via red flags.

**Target environments:** OpenCode (`.agents/skills/`), Claude Code (`.claude/skills/`), Antigravity CLI (`.antigravity/skills/`). Symlink master from `.agents/skills/aposd/`.

## Architecture

Deep module structure: simple interface, powerful implementation.

### Primary interface: `CLAUDE.md`

Follows the Karpathy `CLAUDE.md` format: 10 behavioral rules, each as bold header + italic sub-header + 3-5 bullet points. ~80 lines total. No tables, no rubrics, no YAML frontmatter. This is the always-on behavioral layer — agents follow these rules when writing code. Users paste or symlink this into their project root.

For non-Claude platforms (OpenCode, Antigravity), the same content lives at `skills/aposd/SKILL.md` with YAML frontmatter added for the skill system.

### Implementation: reference docs

Hidden behind the simple interface. Agents delve here when a rule needs deeper guidance.

| File | Purpose |
|---|---|---|
| `CLAUDE.md` | Primary interface — 10 behavioral rules. For Claude Code project root. |
| `skills/aposd/SKILL.md` | Same content as CLAUDE.md + YAML frontmatter. Always-on behavioral skill. |
| `skills/aposd-review/SKILL.md` | Review command skill: red flag scan. Invoked via `{{command_prefix}}aposd review`. |
| `skills/aposd-critique/SKILL.md` | Critique command skill: principles evaluation + tactical assessment. |
| `skills/aposd-audit/SKILL.md` | Audit command skill: severity scoring + tactical tornado detection. |
| `reference/principles.md` | Deep: all 18 principles with examples, limits, complexity mapping |
| `reference/red-flags.md` | Deep: all 16 red flags with detection patterns, priority ordering |
| `agents/aposd-agent.md` | Behavioral rules: strategic/tactical detection, review protocol, modification protocol |
| `README.md` | Install instructions for all platforms |

**CLAUDE.md + skills/aposd/SKILL.md = always-on interface.** Skills/aposd-{review,critique,audit} = one-off commands. Principles.md + Red-flags.md = implementation depth. Agent.md = behavioral engine.

## Core Philosophy

Complexity is the fundamental problem in software design. All principles serve one goal: minimize complexity.

Complexity manifests as three symptoms:
1. **Change amplification** — a single change requires edits in many places
2. **Cognitive load** — how much a developer must hold in their head to make a change
3. **Unknown unknowns** — you don't know what code to change or what to consider

Every principle and red flag traces to one of these three.

## The Compact Interface: CLAUDE.md / SKILL.md

Frontmatter for SKILL.md:

```yaml
name: aposd
description: >-
  Use when reviewing code for design quality, evaluating module boundaries,
  checking interface depth, or identifying complexity problems. Also use when
  writing code that should follow strategic design principles (deep modules,
  information hiding, comments-first, design-for-reading).
```

### CLAUDE.md content (following Karpathy format)

~10 behavioral rules. Each: bold header, italic sub-header, 3-5 bullet points. No tables, no rubrics, no YAML frontmatter. ~70-90 lines total. This is the always-on behavioral layer — agents follow these rules when writing code.

```
# CLAUDE.md

APOSD behavioral guidelines for AI coding agents. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward strategic design over tactical speed. For trivial tasks, use judgment.

## 1. Strategic Over Tactical

*Working code isn't enough. Invest in design.*

- Every task gets a small design investment: at least one improvement in the surrounding code.
- Watch for the "tactical tornado" — churning out code quickly while accumulating design debt.
- Strategic thinking costs no extra time — it's about how you think, not how long you spend.
- If asked for a "quick fix," flag the tradeoff: "Here's the tactical path. The strategic alternative reduces [complexity symptom]."

## 2. Design Deep Modules

*Simple interface, powerful implementation.*

- Module depth = benefit provided / interface complexity. The ratio should be high.
- If the interface is as complex as the implementation, it's shallow — merge or redesign.
- Diagnostic questions: "How many use cases will this serve?" (if one, too special-purpose). "Is this easy to use for my current need?" (if not, redesign).

## 3. Information Hiding

*Expose only what callers need.*

- If implementation details leak into the interface, stop and redesign.
- If the same design decision appears in multiple modules, that's information leakage — consolidate.
- Don't expose internal state unless callers genuinely need it.

## 4. Pull Complexity Downward

*Handle complexity in the implementation, not the interface.*

- The common case must be trivial for the caller.
- When a feature is inherently complex, push that complexity into the module so callers don't see it.
- Don't let the module grow into a god class — if it knows about everything, the interface is simple but the implementation is a tangled mess.

## 5. Comments First

*Describe what's not obvious. If it's hard to write, the design is wrong.*

- Draft the interface comment before writing the body.
- Interface comments: what the method does for callers, not how.
- Implementation comments: why this approach, not what the code does.
- If a comment is hard to write, or long, the design is wrong — redesign.

## 6. Design for Reading

*If someone needs to think hard to understand it, it's not obvious.*

- Run the obviousness check before marking code complete.
- Names should create an image — precise, consistent, no extra words.
- If you can't find an intuitive name, you don't understand the concept well enough.
- Eliminate special cases.

## 7. Define Errors Out of Existence

*Design interfaces so common errors can't happen.*

- Can you change the interface contract to eliminate the error case?
- If not: mask the exception at the right level, aggregate related exceptions, or crash if recovery is meaningless.
- Red flag: complex error-handling that mirrors the happy path — the interface should be redesigned.

## 8. Better Together or Better Apart

*Merge shared concerns. Split different abstractions.*

- Merge modules that share information, would simplify the interface together, or duplicate each other.
- Split when one is general-purpose and the other is special-purpose.
- Split methods only if the child is independently understandable and could be useful elsewhere.
- Red flag: conjoined methods — if you can't understand one without the other, they shouldn't have been split.

## 9. Design It Twice

*Never accept the first design for non-trivial work.*

- Create 2+ alternative designs, list their tradeoffs, pick the best.
- The second design is often better.
- For each alternative: interface sketch, key complexity tradeoffs, which complexity symptom it addresses best.

## 10. Modify Strategically

*Leave every module cleaner than you found it.*

- Stay strategic even during bug fixes or maintenance.
- Comments stay near the code they describe — not in commit messages.
- If your change invalidates a comment, update it.
- Higher-level comments (design rationale, module purpose) are easier to maintain than line-by-line explanations.

---

**Three commands for deeper analysis:**
- `aposd review [target]` — Scan code for red flags.
- `aposd critique [target]` — Evaluate design against principles. Includes tactical vs strategic assessment.
- `aposd audit [target]` — Comprehensive design audit with severity scoring and tactical tornado detection.
```

### Commands as standalone skills

Three command skills, each a SKILL.md with YAML frontmatter, following Karpathy format. Invoked via `{{command_prefix}}aposd <command> [target]`.

**`skills/aposd-review/SKILL.md`** — Red flag scan
- **Frontmatter:** name: `aposd-review`, description: "Use when you need to scan code for design red flags from A Philosophy of Software Design."
- **Content:** Brief intro + 15 red flags listed in priority order with 1-2 line detection patterns.
- **Process:** Scan code for each red flag in priority order. Report found flags with location + suggested fix.
- **Output:** Red flags found (ordered), design score 1-5, top 3 improvements.

**`skills/aposd-critique/SKILL.md`** — Principles-based design evaluation
- **Frontmatter:** name: `aposd-critique`, description: "Use when you need to evaluate code design against APOSD principles and assess whether the development approach was strategic or tactical."
- **Content:** Brief intro + evaluation criteria across all principles.
- **Process:** Evaluate target against all 18 principles. Assess whether code reflects strategic or tactical programming.
- **Output:** Per-principle assessment (passes / at risk / violates), tactical vs strategic diagnosis, design score 1-5, narrative critique.

**`skills/aposd-audit/SKILL.md`** — Comprehensive design audit
- **Frontmatter:** name: `aposd-audit`, description: "Use when you need a systematic audit of code against all APOSD red flags with severity scoring and tactical tornado risk assessment."
- **Content:** Brief intro + severity rubric + audit protocol.
- **Process:** Systematically check all 16 red flags with severity rating. Also evaluate comments, naming, consistency, obviousness. Assess tactical tornado risk.
- **Output:** Per-red-flag table with severity (critical/major/minor/none), category scores (Module Design, Information Hiding, Comments/Naming, Consistency/Obviousness), overall score 1-5, tactical tornado risk (low/medium/high), action items.

### Score rubric (for internal use, not in CLAUDE.md)

| Score | Meaning |
|---|---|
| 5 | Excellent design. Deep interface, clean information hiding, obvious code, good comments. |
| 4 | Good design with minor issues. One or two shallow spots or minor leakage. |
| 3 | Adequate. Several red flags but no fundamental problems. |
| 2 | Poor design. Major red flags (leakage, shallow modules, pass-through chains). |
| 1 | Redesign required. Fundamental complexity problems. |

## Reference Documents

Behind the compact interface, three reference docs provide depth:

### `reference/principles.md` — Design Principles Deep Reference

One section per principle, each with:
- **Name and book reference**
- **Core idea** (2-3 sentences)
- **Why it reduces complexity** (maps to one of the three symptoms)
- **Taking it too far** (specific limit and detection signal)
- **Example** (before/after code sketch or book example reference)

Principles covered:
1. Strategic over tactical programming (Ch 3)
2. Deep modules (Ch 4) — THE principle
3. Information hiding and leakage (Ch 5)
4. General-purpose modules are deeper (Ch 6)
5. Different layer, different abstraction (Ch 7) — includes pass-through methods and variables
6. Pull complexity downward (Ch 8)
7. Better together or better apart (Ch 9) — split/join decision framework
8. Define errors out of existence (Ch 10)
9. Design it twice (Ch 11)
10. Comments describe non-obvious (Ch 13) — interface vs implementation, cross-module decisions
11. Comments-first (Ch 15)
12. Choosing names (Ch 14) — create an image
13. Modifying existing code (Ch 16)
14. Consistency (Ch 17)
15. Code should be obvious (Ch 18)
16. Design for the future (Ch 21)
17. Performance as design (Ch 20)
18. Increments are abstractions, not features (Ch 3/22)

Plus awareness sections: Software trends (Ch 19), Taking it too far (summary).

### `reference/red-flags.md` — Red Flags Deep Reference (15 red flags)

One section per red flag, each with:
- **Name, priority rank, book reference**
- **Symptom** (what it looks like in code)
- **Why it increases complexity** (which symptom)
- **Detection pattern** (specific code patterns to look for)
- **Fix strategy** (APOSD-aligned approach)

Red flags in priority order:
1. Information Leakage (most important)
2. Shallow Module
3. Temporal Decomposition
4. Pass-Through Method
5. Pass-Through Variables
6. Repetition
7. Special-General Mixture
8. Conjoined Methods
9. Overexposure
10. Comment Repeats Code
11. Implementation Documentation Contaminates Interface
12. Vague Name
13. Hard to Pick Name
14. Hard to Describe
15. Nonobvious Code

## The Agent (aposd-agent.md)

### Always-on behavioral rules

When writing code, the agent follows these rules:

1. **Strategic programming** — Every task gets a small strategic investment. Before implementing, ask: "Is there a design improvement opportunity here?" Watch for the "tactical tornado" anti-pattern: churning out large volumes of code quickly while leaving design debt. Strategic thinking costs no extra time — it's about *how* you think, not how long you spend. The 10-20% is operationalized as: for every file touched, identify at least one design improvement in the immediate area (same module, adjacent functions, caller/callee chain) and implement it alongside the primary task. "Effort" = changes that add ≤20% more lines or ≤20% more time than the tactical fix alone.

2. **Deep modules** — Every new module (class, function, subsystem) is evaluated by its interface-to-implementation ratio. Module depth = benefit (functionality provided) / cost (interface complexity). A simple interface that hides powerful functionality is the goal. If the interface is as complex as the implementation, it's a shallow module — merge it or redesign. Use Ousterhout's diagnostic questions: "In how many situations will this method be used?" (if one, it's too special-purpose) and "Is this API easy to use for my current needs?" (if not, redesign).

3. **Information hiding** — Expose only what consumers need. If implementation details leak into the interface, stop and redesign. If information is shared across modules ("leakage"), consolidate or re-encapsulate.

4. **Comments-first** — For every new module or method, draft the interface comment before writing the body. Two types: **interface comments** describe what the module does for its callers (contract, not mechanism). **Implementation comments** describe why the approach was chosen (not what the code does — that's obvious from code). If a comment is hard to write, the design is wrong. If the comment is long, the design is probably wrong. If you must repeat implementation details in an interface comment, information is leaking.

5. **Design for reading, not writing** — Optimize for the future maintainer. Obviousness test: "If someone else reads this and needs to think hard to understand it, the code is not obvious." Run this as a pre-commit check on every module. Use names that "create an image" — precise, consistent, no extra words. If you can't find a precise, intuitive name for something, you don't understand it well enough — redesign. Eliminate special cases.

6. **Pull complexity downward** — When a feature has inherent complexity, push it into the module's implementation so the caller's interface stays simple. The common case should be trivial.

7. **Design it twice** — Never accept the first design for a non-trivial component. Create 2+ alternatives, list tradeoffs, pick the best. The second design is often better. Output format: for each alternative, produce (a) interface sketch (b) key complexity tradeoffs (c) which complexity symptom it addresses best. Then select with rationale.

8. **Moderate consistency enforcement** — Flag naming/pattern inconsistencies and suggest fixes. Don't block.

9. **Better Together or Better Apart** — When deciding whether to split or merge modules, use this decision framework:
   - **Bring together** if: information is shared between them, merging simplifies the overall interface, or merging eliminates duplication
   - **Keep separate** if: one is general-purpose and the other is special-purpose, or they address different abstraction levels
   - **Split methods** only if: the child method is independently understandable (you don't need to flip between parent and child), and the child is general-purpose enough to be used elsewhere
   - **Red flag**: Conjoined Methods — if you can't understand one method without understanding the other, they shouldn't have been split

10. **Modifying Existing Code** — Ch 16 protocol:
    - Stay strategic: every modification is an opportunity to improve the design of surrounding code
    - Keep comments near the code they describe — don't move documentation into commit messages
    - Document decisions in code, not commits: commit messages are temporal, code is permanent
    - Avoid documentation duplication — one source of truth
    - Check diffs for documentation impacts: if your change invalidates a comment, update it
    - Higher-level comments (describing module purpose, design rationale) are easier to maintain than line-by-line explanations

11. **Define errors out of existence** — When designing interfaces, consider: "can I make this error impossible to encounter?" Techniques: (a) eliminate the error case by changing the interface contract (b) mask the exception at the right abstraction level (c) aggregate many exception types into one (d) crash if recovery is meaningless. Red flag: complex error-handling code that duplicates the "happy path" logic is often a sign the interface should be redesigned.

12. **Cross-module design decisions documented** — When making a decision that affects multiple modules, write a comment (at the decision point or in a shared location) describing: what was decided, why, and what alternatives were considered. This prevents "unknown unknowns" — future maintainers won't know the decision was made.

13. **Increments should be abstractions, not features** — Decompose tasks by abstraction boundary, not by feature. Example: "add the text formatting toolbar" → decompose as "implement the formatting interface" (deep module), then "build the toolbar UI on top of it." Don't decompose as "add bold button, then italic button, then underline button" (temporal decomposition).

14. **Design for the future** — When designing a module, identify which aspects are likely to change and which are stable. Encapsulate the volatile parts. Don't add hooks/configurability for hypothetical futures — only for changes you have reasonable evidence will occur. Prefer deletion over extension: the simplest way to prepare for the future is to keep the system small.

15. **Performance as a design concern** — Design-level decisions (module boundaries, data structures, communication patterns) dominate performance far more than micro-optimizations. Clean designs are easier to profile and optimize. Never sacrifice design clarity for speculative performance gains. Measure before optimizing.

### Review protocol

When `aposd review` is invoked:

1. Scan code for red flags in priority order: Information Leakage → Shallow Module → Temporal Decomposition → Pass-Through Method → Pass-Through Variables → Repetition → Special-General Mixture → Conjoined Methods → Overexposure → Comment/Name/Obviousness red flags
2. For each red flag found, provide: (a) location (b) why it increases complexity (c) which symptom: change amplification / cognitive load / unknown unknowns (d) APOSD-aligned alternative
3. Score: 1-5 (1 = redesign required, 5 = excellent design)
4. Top 3 improvements ranked by complexity reduction potential

### Tactical vs Strategic detection

The agent maintains awareness of whether it's being asked for tactical or strategic work:
- **Tactical request** (bug fix, quick patch): The agent provides the fix AND identifies 1-2 adjacent design problems (same module, directly related code) to improve while the context is fresh
- **Strategic request** (new feature, refactor): The agent invokes "design it twice" before implementation
- **Mixed signal**: When the user says "just make it work" or "quick fix," the agent explicitly flags:
  > "This is a tactical approach. The strategic alternative would be [X], which reduces [complexity symptom] by [means]. I'll proceed tactically unless you prefer the strategic path."

### Adjacent improvement boundary

"Adjacent" means: same file, same module, or directly in the call chain of the code being modified. The agent does not hunt for problems in unrelated parts of the codebase. This prevents scope creep while still enabling the "leave it cleaner" pattern.

### Naming convention

- Commands use `aposd-` prefix to avoid namespace collisions
- Template variables: `{{command_prefix}}`, `{{model}}`, `{{scripts_path}}`

### Testing (RED-GREEN-REFACTOR)

Per the writing-skills skill. Four pressure scenarios:

1. **Tactical shortcut pressure** — Subagent asked to fix a bug "quickly." Without skill: does it patch without improving surrounding design? With skill: does it identify adjacent improvements and invest 10-20%?

2. **Shallow module detection** — Subagent presented with code containing pass-through methods, temporal decomposition, or classitis. Without skill: does it flag these as problems? With skill: does it identify the specific red flag and suggest a deep module restructuring?

3. **Comments-first compliance** — Subagent asked to implement a new module. Without skill: does it write code then comments (or skip comments)? With skill: does it draft interface comments first, and recognize "hard to describe" as a design problem?

4. **Define errors out of existence** — Subagent asked to implement an interface with complex error handling. Without skill: does it propagate errors blindly? With skill: does it consider interface redesign to eliminate error cases?

For each: run WITHOUT skill (baseline), run WITH skill (verify), then close loopholes (refactor).

## Directory Structure

```
aposd-skills/
  CLAUDE.md                     # Primary — 10 behavioral rules (Claude Code project root)
  skills/
    aposd/SKILL.md              # Always-on behavioral skill (same as CLAUDE.md + frontmatter)
    aposd-review/SKILL.md       # Review command: red flag scan
    aposd-critique/SKILL.md     # Critique command: principles + tactical assessment
    aposd-audit/SKILL.md        # Audit command: severity scoring + tornado detection
  reference/
    principles.md               # Deep: 18 principles with examples, limits
    red-flags.md                # Deep: 16 red flags with detection patterns
  agents/
    aposd-agent.md              # Behavioral rules for APOSD-compliant coding
  README.md                     # Install: curl, symlink, plugin
