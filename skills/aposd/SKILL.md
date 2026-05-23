---
name: aposd
description: Use when writing, reviewing, or modifying any code. Also use when code has shallow modules, information leakage, pass-through methods, duplicated logic, vague names, or accumulating design debt from tactical shortcuts.
license: MIT
---

> **Content source:** `CLAUDE.md` is the single source of truth for the 10 behavioral rules — make changes to those there first, then copy here. Sections unique to this file (Setup, Quick Reference, Common Mistakes, Routing Rules) are maintained here directly. See `docs/adr/005-claude-sk-condensation.md`.

# APOSD behavioral guidelines

## Setup

Before coding: load context (README, CLAUDE.md, existing code), identify task type (bug fix, feature, refactor), and scan for design red flags (shallow modules, information leakage, pass-through methods). Skipping these produces generic output.

## Principles

**Tradeoff:** Bias toward strategic design. For trivial tasks, use judgment.

### 1. Strategic Over Tactical

*Working code isn't enough. Invest in design.*

- Every task gets a design investment: one improvement in the surrounding code.
- Watch for the "tactical tornado" — churning out code quickly while accumulating debt.
- Strategic thinking costs no extra time.
- BEFORE implementing, state the strategic alternative: "[quick fix] vs [redesign]. Recommend strategic unless time constraints require otherwise."
- **Red flag:** Using APOSD vocabulary to justify a tactical patch — language doesn't make it strategic, design investment does.

### 2. Design Deep Modules

*Simple interface, powerful implementation.*

- Module depth = benefit / interface complexity. Maximize the ratio.
- If the interface is as complex as the implementation, it's shallow — merge or redesign.
- Diagnostic question: "How many use cases will this serve?" (if one, too special-purpose).

### 3. Information Hiding

*Expose only what callers need.*

- If implementation details leak into the interface, stop and redesign.
- If the same design decision appears in multiple modules, that's information leakage — consolidate.
- Don't expose internal state unless callers genuinely need it.

### 4. Pull Complexity Downward

*Handle complexity in the implementation, not the interface.*

- The common case must be trivial for the caller.
- Push inherent complexity into the module so callers don't see it.
- Don't let the module grow into a god class.

### 5. Comments First

*Comments are essential, not a failure. If a comment is hard to write, the design is wrong.*

- Draft the interface comment before writing the body.
- Interface comments: what the method does for callers, not how.
- Implementation comments: why this approach, not what the code does.
- If a comment is hard to write or long, the design is wrong — redesign.
- **Note:** Without comments, every method's contract is unspecified — readers must read the full implementation.

### 6. Design for Reading

*If someone needs to think hard to understand it, it's not obvious. Complexity is in the eye of the reader — that's your problem to fix.*

- Run the obviousness check: "Would a first-time reader understand this without effort?"
- Names should create an image — precise, consistent, no extra words.
- If you can't find an intuitive name, redesign, don't rename.
- Eliminate special cases. Every special case adds cognitive load.

### 7. Define Errors Out of Existence

*Design interfaces so common errors can't happen.*

- Can you change the interface contract to eliminate the error case?
- If not: mask at the right level, aggregate, or crash if recovery is meaningless.
- Red flag: error-handling that mirrors the happy path — redesign the interface.

### 8. Better Together or Better Apart

*Merge shared concerns. Split different abstractions.*

- Merge modules that share information, simplify the interface together, or duplicate each other.
- Split when one is general-purpose and the other special-purpose.
- Split methods only if the child is independently understandable.
- Red flag: conjoined methods — if you can't understand one without the other, don't split them.

### 9. Design It Twice

*Never accept the first design for non-trivial work.*

- Create 2+ alternatives, list tradeoffs, pick the best.
- The second design is often better.
- For each: interface sketch, complexity tradeoffs, which symptom it addresses.

### 10. Modify Strategically

*Leave every module cleaner than you found it.*

- Stay strategic even during bug fixes or maintenance.
- Comments stay near the code they describe, not in commit messages.
- If your change invalidates a comment, update it.
- Higher-level comments (design rationale, module purpose) outlast line-by-line explanations.

---

**Commands:**
- `aposd critique [target]` — Design evaluation against principles + tactical assessment.
- `aposd audit [target]` — Design audit with severity scoring and tactical tornado detection.

## Quick Reference

| Principle | Red Flag | Fix |
|-----------|----------|------|
| Deep Modules | Interface as complex as implementation | Merge or redesign |
| Information Hiding | Same decision in multiple places | Consolidate |
| Pull Complexity Downward | Caller does complex setup | Move into module |
| Comments First | Hard to write the comment | Redesign interface |
| Define Errors | Error-handling mirrors happy path | Change contract |

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Applying all 10 rules rigidly | Rules have limits | Use the complexity lens |
| Calling a patch "strategic" | Vocabulary ≠ design investment | If the interface didn't change, it's tactical |
| Skipping "design it twice" | First designs are rarely best | Even 2 minutes of alternatives improves outcomes |
| Writing comments after code | Comments become afterthoughts | Draft interface comment before implementation |

## Routing Rules

1. **No explicit command**: Apply the 10 rules as always-on behavior while writing code. No invocation needed.
2. **First word matches a command** (`aposd critique` or `aposd audit`): Load the corresponding skill file from `skills/aposd-{command}/SKILL.md` and follow its instructions. Everything after the command name is the target.
3. **User says "just make it work" or "quick fix"**: Follow rule 1 (Strategic Over Tactical) — state the strategic alternative before proceeding tactically.

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Too small to design" | Every task gets a design investment. |
| "I'm using APOSD vocabulary" | Vocabulary without design investment is still tactical. |
| "I'll add comments after" | Comments are design tools, not afterthoughts. |
| "No time to design it twice" | Even two minutes of alternative thinking improves outcomes. |
| "Only serves one use case" | If it serves one caller, it's too special-purpose — generalize. |

## Red Flags — STOP and Start Over

- Using APOSD vocabulary to justify a tactical patch
- Writing implementation before the interface comment
- Exposing implementation details in the interface
- Requiring the caller to do complex setup or handle error cases
- Being unable to name a concept without vague or multi-word terms
- Error-handling code that mirrors the happy path
- Making any change without leaving the surrounding module cleaner
