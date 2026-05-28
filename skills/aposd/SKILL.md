---
name: aposd
description: 'Use when making design decisions: module boundaries, interfaces, error handling, naming. Not for one-line fixes.'
license: MIT
in_scope:
  - Design analysis
  - Modular decomposition
  - Interface design
  - Naming decisions
  - Error-handling strategy
  - Abstraction layering
  - Code review with design lens
out_of_scope:
  - Low-level debugging
  - Performance profiling
  - Framework-specific patterns
  - CI/CD configuration
  - Deployment infrastructure
  - Security auditing
---

> **Content source:** `CLAUDE.md` is the single source of truth for the 15 behavioral rules — make changes to those there first, then copy here. Sections unique to this file (Setup, Quick Reference, Common Mistakes, Invocation Modes) are maintained here directly. See ADR-005 (Intentional Condensation). Examples in `references/`.

# APOSD behavioral guidelines

Design-quality guardrails for every coding task. APOSD applies 15 principles from *A Philosophy of Software Design* (Ousterhout) — always-on behavioral guidance that pushes toward deeper modules, cleaner interfaces, and less error handling for callers. No explicit invocation needed for everyday coding.

## Scope

**In scope:** Design analysis, modular decomposition, interface design, naming, error-handling strategy, abstraction layering, code review with a design lens.

**Deliberately out of scope:**
- Low-level debugging or performance profiling
- Framework-specific patterns (React, Django, etc.)
- CI/CD configuration, deployment, infrastructure
- Security auditing — see the dedicated security skills

**Boundary with sibling skills:** This skill provides design *principles* and behavioral guidance. The sibling skills below cover formal evaluation passes:

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| **aposd** (this skill) | Always-on design principles during coding | Every task with design decisions |
| [**aposd-critique**](../aposd-critique/SKILL.md) | Principles-based design evaluation | Deep design review, second opinion on complexity |
| [**aposd-audit**](../aposd-audit/SKILL.md) | Severity-scored design audit | Before major refactoring, baseline current state |

## When Not to Use

This skill is designed for non-trivial design decisions. Skip it for:
- Trivial one-line fixes (typo, variable rename, config change)
- Mechanical refactors with no design impact (rename a method, extract a constant)
- Exploratory code where the design is intentionally provisional

The tradeoff note at the top of Principles covers this: "For trivial tasks, use judgment."

## Invocation Modes

Three invocation patterns — see [`references/routing.md`](references/routing.md) for the full routing table and fallback behavior.

## Setup

### Quick start
1. Load project context (README, CLAUDE.md, existing code)
2. Identify task type (bug fix, feature, refactor)
3. Scan for design red flags (shallow modules, info leakage, pass-through methods)
4. Apply the relevant principle — the first three below cover most cases

### Full setup
Before coding: load context (README, CLAUDE.md, existing code), identify task type (bug fix, feature, refactor), and scan for design red flags (shallow modules, information leakage, pass-through methods). Skipping these produces generic output.

## Input / Output

This skill modifies agent behavior during any coding task:
- **Input** — A coding task: writing new code, reviewing existing code, refactoring, debugging, or designing.
- **Output** — Code modified by the 15 principles: deeper module boundaries extracted, pass-through layers eliminated, vague names replaced, error cases removed from caller paths. The Quick Reference table below maps each principle to its observable effect.
- **Fallback** — If the task is trivial, out of scope, or doesn't match a design scenario, the skill remains silent and normal agent behavior proceeds without APOSD guidance.

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

## Review discipline

When evaluating or modifying design, do not stop at the first workable answer.

1. Identify the smallest meaningful target and the caller-facing problem.
2. Compare at least two plausible designs or fixes before choosing one.
3. Tie every recommendation to a concrete design principle or red flag.
4. Prefer the change that removes future decisions from callers and leaves the module cleaner.
5. Keep the everyday skill lightweight; use the deeper critique and audit skills when you need a formal review pass.

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

## Robustness

> **Degradation guarantee:** When the skill can't complete, it exits silently with no side effects. No partial output, no misleading results.

This skill documents every failure path explicitly:

| Condition | Behavior | Recovery |
|-----------|----------|----------|
| **Mis-triggered** (task isn't a design scenario) | Falls through silently | Normal agent behavior proceeds unaffected |
| **Principles conflict** (e.g., General-Purpose vs Simplicity) | Principles have tension by design | Use the complexity lens: the option that better reduces cognitive load wins |
| **Vocabulary used without design depth** | Agent references APOSD but interface didn't change | Check if the interface actually changed. If not, it's tactical regardless of language |
| **User explicitly rejects strategic approach** | Falls back to tactical, documents the tradeoff | State the tradeoff, document it, then proceed |
| **Target not found or empty** | Report and exit | No code changes made |
| **Target too large** (>50 files) | Use sub-agents to parallelize scanning | Report total files scanned |

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

## Code Templates

### Deep module scaffold

Hide connection lifecycle, error handling, and retry logic behind a one-line interface.

See [`templates/deep-module.py`](templates/deep-module.py) for a complete working implementation.

### Error-eliminating decorator

Wrap a fallible API so callers never see the error case.

See [`templates/error-suppressor.py`](templates/error-suppressor.py) for a complete working implementation.

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

### Design It Twice (Rule 12)

Scenario: a service needs to authenticate users via API keys, OAuth, and SSO.

**Design A — Monolithic Auth class:**

```python
class Authenticator:
    # Single class handles all strategies — 3+ methods per auth type
    def authenticate_api_key(self, key: str) -> User: ...
    def authenticate_oauth(self, token: str) -> User: ...
    def authenticate_sso(self, assertion: str) -> User: ...
    # Caller must pick the right method — tight coupling to auth type
```

*Tradeoff:* Simple to start, but every new auth type adds methods to this class. Callers must know which method to call. Testing requires exercising all strategies through one class.

**Design B — Strategy pattern with pluggable providers:**

```python
class AuthProvider(Protocol):
    def authenticate(self, credentials: str) -> User: ...

class Authenticator:
    # One method, any provider
    def authenticate(self, provider: AuthProvider, credentials: str) -> User: ...
```

*Tradeoff:* More files upfront. But callers never change — they always call `authenticator.authenticate(provider, creds)`. New auth types mean new provider classes, no changes to `Authenticator`. Testing each provider is isolated.

**Verdict:** Design B is deeper — same caller interface regardless of auth type. The implementation complexity (which provider to use, credential format) is pushed to the provider implementations, not the caller.

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

## Troubleshooting

See [`references/troubleshooting.md`](references/troubleshooting.md) for the full failure-mode catalog (6+ scenarios with causes and fixes).

## Related

- [aposd-critique](../aposd-critique/SKILL.md) — Design evaluation command
- [aposd-audit](../aposd-audit/SKILL.md) — Design audit command
- [references/](references/) — Extended examples
