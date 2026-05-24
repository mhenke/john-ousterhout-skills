---
name: aposd
description: Use when writing, reviewing, or modifying any code. Also use when code has shallow modules, information leakage, pass-through methods, duplicated logic, vague names, or accumulating design debt from tactical shortcuts.
license: MIT
---

> **Content source:** `CLAUDE.md` is the single source of truth for the 15 behavioral rules — make changes to those there first, then copy here. Sections unique to this file (Setup, Quick Reference, Common Mistakes, Routing Rules) are maintained here directly. See ADR-005 (Intentional Condensation). Examples and troubleshooting in `references/`.

# APOSD behavioral guidelines

## Routing Rules

1. **No explicit command**: Apply the 15 rules as always-on behavior while writing code. No invocation needed.
2. **First word matches a command** (`aposd critique` or `aposd audit`): Load the corresponding skill file (`skills/aposd-critique/SKILL.md` or `skills/aposd-audit/SKILL.md`) and follow its instructions. Everything after the command name is the target.
3. **User says "just make it work" or "quick fix"**: Follow rule 1 (Strategic Over Tactical) — state the strategic alternative before proceeding tactically.

## Red Flags — STOP and Start Over

- Using APOSD vocabulary to justify a tactical patch
- Writing implementation before the interface comment
- Exposing implementation details in the interface
- Special-case logic embedded in a general-purpose mechanism
- Pass-through methods or variables that add no abstraction value
- Requiring the caller to do complex setup or handle error cases
- Being unable to name a concept without vague or multi-word terms
- Error-handling code that mirrors the happy path
- Adding hooks for hypothetical future requirements
- Decomposing work by execution order instead of abstraction boundaries
- Making any change without leaving the surrounding module cleaner

## Setup

Before coding: load context (README, CLAUDE.md, existing code), identify task type (bug fix, feature, refactor), and scan for design red flags (shallow modules, information leakage, pass-through methods). Skipping these produces generic output.

## Input / Output

This skill modifies agent behavior during any coding task:
- **Input** — A coding task: writing new code, reviewing existing code, refactoring, debugging, or designing.
- **Output** — Code modified by the 15 principles: deeper module boundaries extracted, pass-through layers eliminated, vague names replaced, error cases removed from caller paths. The Quick Reference table below maps each principle to its observable effect.

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

### 4. Design General-Purpose Modules

*Serve multiple use cases through a stable interface.*

- Design modules to be slightly more general-purpose than your current need. A general-purpose module is reused, not duplicated, and its interface stays stable across use cases.
- If a module or method serves only one caller, it may be too special-purpose — generalize it.
- Diagnostic questions: "In how many situations could this method be used?" (if one, too special). "Is this API easy to use for my current need?" (if not, redesign). "Can several special-purpose methods be replaced by one general-purpose method?"
- Red flag: special-case logic embedded in a general-purpose mechanism — separate the two so the mechanism stays reusable.

### 5. Different Layer, Different Abstraction

*Each layer must add value — pass-throughs are noise.*

- Every software layer should provide a different abstraction from the layers above and below it. If two adjacent layers have similar abstractions, one of them isn't adding value.
- Pass-through methods (method body only delegates with the same signature) and pass-through variables (config threaded through layers that don't use it) are red flags — eliminate them.
- Diagnostic question: "Does removing this layer change anything meaningful for the caller?" If not, delete it.

### 6. Pull Complexity Downward

*Handle complexity in the implementation, not the interface.*

- The common case must be trivial for the caller.
- Push inherent complexity into the module so callers don't see it.
- Don't let the module grow into a god class.

### 7. Comments First

*Comments are essential, not a failure. If a comment is hard to write, the design is wrong.*

- Draft the interface comment before writing the body.
- Interface comments: what the method does for callers, not how.
- Implementation comments: why this approach, not what the code does.
- If a comment is hard to write or long, the design is wrong — redesign.
- **Note:** Without comments, every method's contract is unspecified — readers must read the full implementation.

### 8. Choosing Names

*Names should create an image — precise, consistent, no extra words.*

- If you can't find an intuitive name, you don't understand the concept well enough — redesign, don't rename.
- Avoid vague names: `data`, `info`, `tmp`, `handle`, `process`, `util`, `helper`, `manager`, `stuff`, `thing`.
- A good name is precise enough to distinguish and short enough to read. If a name needs extra words to clarify, the concept is fuzzy.
- Consistency across the codebase matters — the same concept should always have the same name.

### 9. Design for Reading

*If someone needs to think hard to understand it, it's not obvious. Complexity is in the eye of the reader — that's your problem to fix.*

- Run the obviousness check: "Would a first-time reader understand this without effort?"
- Eliminate special cases. Every special case adds cognitive load.
- Good naming, simple control flow, and minimal state make code obvious. If it's not obvious, redesign — don't add comments explaining it.

### 10. Define Errors Out of Existence

*Design interfaces so common errors can't happen.*

- Can you change the interface contract to eliminate the error case?
- If not: mask at the right level, aggregate, or crash if recovery is meaningless.
- Red flag: error-handling that mirrors the happy path — redesign the interface.

### 11. Better Together or Better Apart

*Merge shared concerns. Split different abstractions.*

- Merge modules that share information, simplify the interface together, or duplicate each other.
- Split when one is general-purpose and the other special-purpose.
- Split methods only if the child is independently understandable.
- Red flag: conjoined methods — if you can't understand one without the other, don't split them.

### 12. Design It Twice

*Never accept the first design for non-trivial work.*

- Create 2+ alternatives, list tradeoffs, pick the best.
- The second design is often better.
- For each: interface sketch, complexity tradeoffs, which symptom it addresses.

### 13. Design for the Future

*Identify what's likely to change and encapsulate it.*

- Encapsulate volatile parts behind stable interfaces. Don't add hooks for hypothetical futures — only for changes you have reasonable evidence will occur.
- Prefer deletion over extension. Delete what's no longer needed.
- Over-engineering for hypothetical futures is as bad as under-engineering for real ones.

### 14. Increments Are Abstractions

*Decompose by abstraction boundary, not by feature.*

- A new feature should be implemented as "create the abstraction layer" first, then "build the feature on top of it."
- Don't decompose by execution order or UI surface area. "Add bold button, then italic button, then underline button" is wrong — implement the formatting interface first, then build the toolbar on top.
- Each increment should produce a working system at a new abstraction level, not a partial feature sliced by execution order.

### 15. Modify Strategically

*Leave every module cleaner than you found it.*

- Stay strategic even during bug fixes or maintenance.
- Comments stay near the code they describe, not in commit messages.
- If your change invalidates a comment, update it.
- Higher-level comments (design rationale, module purpose) outlast line-by-line explanations.

## Quick Reference

| Principle | Red Flag | Fix |
|-----------|----------|------|
| Deep Modules | Interface as complex as implementation | Merge or redesign |
| Information Hiding | Same decision in multiple places | Consolidate |
| General-Purpose Modules | Serves only one caller | Generalize the interface |
| Different Layer | Pass-through method or variable chain | Eliminate the layer |
| Pull Complexity Downward | Caller does complex setup | Move into module |
| Comments First | Hard to write the comment | Redesign interface |
| Choosing Names | Vague name like `data`, `handle` | Rename to create an image |
| Define Errors | Error-handling mirrors happy path | Change contract |
| Design for Future | Hooks for hypothetical scenarios | Only encapsulate known volatility |

## Examples

### Tactical vs strategic (Rule 1 + 2)

```python
# Tactical: caller manages email lifecycle
notifier = EmailNotifier()
notifier.connect()
notifier.send(user.email, message)
notifier.disconnect()

# Strategic: one-line interface, complexity inside
NotificationService().send(user, message)
```

### Error elimination (Rule 10)

```python
# Before: every caller handles None
user = db.query("SELECT * FROM users WHERE id = ?", uid).fetchone()
if user is None:
    return default_user()

# After: Optional expresses "not found" as valid state
user = db.query("SELECT * FROM users WHERE id = ?", uid).first()
```

### Pass-through elimination (Rule 5)

```python
# Before: controller passes through to service
def update_user(request):
    return UserService().update(request.user_id, request.data)

# After: controller owns its abstraction
def update_user(request):
    return self.user_service.update(request.user_id, request.data)
```

More examples in `references/examples.md`.

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Applying all 15 rules rigidly | Rules have limits | Use the complexity lens |
| Calling a patch "strategic" | Vocabulary ≠ design investment | If the interface didn't change, it's tactical |
| Skipping "design it twice" | First designs are rarely best | Even 2 minutes of alternatives improves outcomes |
| Writing comments after code | Comments become afterthoughts | Draft interface comment before implementation |
| "Too small to design" | Every task deserves investment | Even trivial changes should leave code cleaner |
| "No time to design" | No time to fix it later either | Two minutes of alternative thinking is free |
| "Only serves one use case" | Special-purpose code proliferates | Generalize the interface |

## Commands

- `aposd critique [target]` — Design evaluation against principles + tactical assessment.
- `aposd audit [target]` — Design audit with severity scoring and tactical tornado detection.

## Related

- [aposd-critique](skills/aposd-critique/SKILL.md) — Design evaluation command
- [aposd-audit](skills/aposd-audit/SKILL.md) — Design audit command
- [references/](references/) — Extended examples and troubleshooting
