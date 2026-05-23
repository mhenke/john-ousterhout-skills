---
name: aposd
description: Use when code has shallow modules, information leakage, pass-through methods, vague names, duplicated logic, or other complexity problems. Also use when writing new code and you want to avoid accumulating design debt from tactical shortcuts.
license: MIT
---

> **Content source:** This file mirrors `CLAUDE.md`. `CLAUDE.md` is the single source of truth — make changes there first, then copy here.

# APOSD behavioral guidelines

Guides AI coding agents to write software with strategic design depth. Real complexity reduction, intentional module boundaries, exceptional craft.

## Setup

Before any code writing or file editing:

1. **Load context** — Read the project's README, CLAUDE.md, and any existing code to understand the current design patterns.
2. **Identify the task type** — Is this a bug fix (tactical), a new feature (strategic), or a refactor (design improvement)? Each maps to a different response.
3. **Check for red flags in existing code** — Before modifying, scan the immediate area for shallow modules, information leakage, or pass-through methods. If found, note them as improvement opportunities.

Skipping these produces generic output that ignores the project's existing design.

## Design Principles (The 10 Rules)

**Tradeoff:** These guidelines bias toward strategic design over tactical speed. For trivial tasks, use judgment.

### 1. Strategic Over Tactical

*Working code isn't enough. Invest in design.*

- Every task gets a small design investment: at least one improvement in the surrounding code.
- Watch for the "tactical tornado" — churning out code quickly while accumulating design debt.
- Strategic thinking costs no extra time — it's about how you think, not how long you spend.
- BEFORE implementing any fix, explicitly state the strategic alternative: "Here's the tactical path: [quick fix]. The strategic alternative: [redesign that reduces complexity]. I recommend the strategic approach unless time constraints require otherwise."
- **Red flag:** If you find yourself using APOSD vocabulary ("deep module," "define errors out of existence") to justify a tactical patch, you're still being tactical. Language doesn't make it strategic — design investment does.

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

*Describe what's not obvious. Comments are not a failure — they are essential. If a comment is hard to write, the design is wrong.*

- Draft the interface comment before writing the body.
- Interface comments: what the method does for callers, not how.
- Implementation comments: why this approach, not what the code does.
- If a comment is hard to write, or long, the design is wrong — redesign.
- **Note:** APOSD disagrees with "comments are failures" philosophy. Without comments, there is no way to define abstractions or module interfaces — the contract of every method is left unspecified, forcing readers to read the full implementation. Ousterhout reports spending 50-80% of development time wading through code due to inadequate documentation.

## 6. Design for Reading

*If someone needs to think hard to understand it, it's not obvious. Complexity is in the eye of the reader — if someone finds your code complicated, it IS complicated, and that's your problem to fix, not theirs to overcome.*

- Run the obviousness check before marking code complete: "Would someone reading this for the first time understand it without effort?"
- Names should create an image — precise, consistent, no extra words.
- If you can't find an intuitive name, you don't understand the concept well enough — redesign, don't rename.
- Eliminate special cases. Every special case adds cognitive load for every future reader.

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
- Red flag: conjoined methods (entanglement) — if you can't understand one without the other, they shouldn't have been split.

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

**Two commands for deeper analysis:**
- `aposd critique [target]` — Evaluate design against principles + tactical vs strategic assessment.
- `aposd audit [target]` — Comprehensive design audit with severity scoring and tactical tornado detection.

---

**These guidelines are working if:** you see fewer pass-through chains and shallow classes, comments are written before code, errors are eliminated rather than handled, and codebases improve with each modification instead of accumulating design debt.

## Quick Reference

| Principle | Red Flag | Fix |
|-----------|----------|-----|
| Deep Modules | Interface as complex as implementation | Merge with caller or redesign for depth |
| Information Hiding | Same decision in multiple modules | Consolidate into one module |
| Pull Complexity Downward | Caller does complex setup | Move complexity into the module |
| Comments First | Hard to write the comment | Redesign the interface |
| Define Errors Out of Existence | Error-handling mirrors happy path | Change the interface contract |

## Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| Applying all 10 rules rigidly | Every rule has limits ("taking it too far") | Use the complexity lens: does this rule reduce complexity here? |
| Calling a patch "strategic" | Language doesn't make it design investment | If you didn't change the interface or module boundary, it's tactical |
| Skipping "design it twice" for speed | First designs are almost never the best | Even 2 minutes of alternative thinking improves outcomes |
| Writing comments after code | Comments become afterthoughts, not design tools | Draft interface comment before implementation body |

## Routing Rules

1. **No explicit command**: Apply the 10 rules as always-on behavior while writing code. No invocation needed.
2. **First word matches a command** (`aposd critique` or `aposd audit`): Load the corresponding skill file from `skills/aposd-{command}/SKILL.md` and follow its instructions. Everything after the command name is the target.
3. **User says "just make it work" or "quick fix"**: Follow rule 1 (Strategic Over Tactical) — state the strategic alternative before proceeding tactically.
