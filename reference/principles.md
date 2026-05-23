# Design Principles — Deep Reference

From *A Philosophy of Software Design, 2nd Edition* (Ousterhout, 2021). Each principle includes core idea, complexity symptom it addresses, taking-it-too-far limit, and an example.

See also Ousterhout's [APOSD vs Clean Code discussion](https://github.com/johnousterhout/aposd-vs-clean-code) with Robert Martin for concrete contrasts between these principles and Clean Code's approach.

---

## 1. Strategic Over Tactical Programming

**Book reference:** Ch 3

**Core idea:** Most programmers work tactically — get something working, move on. This accumulates complexity. Strategic programming invests a small amount in good design with every task. Working code isn't enough; the design must be sound.

**Why it reduces complexity:** Prevents accumulation of design debt. Each tactical shortcut adds complexity that compounds over time.

**Taking it too far:** Analysis paralysis. The goal is 10-20% design investment, not redesigning everything from scratch. Strategic thinking is about how you think, not how long you spend.

**Example:** A bug fix is an opportunity to improve the design of the surrounding code, not just patch the symptom.

---

## 2. Deep Modules

**Book reference:** Ch 4

**Core idea:** The most important design idea. Module depth = benefit (functionality provided) / cost (interface complexity). A deep module provides powerful functionality through a simple interface. A shallow module has an interface as complex as its implementation.

**Why it reduces complexity:** Deep modules hide complexity behind a simple interface, reducing cognitive load for callers. Shallow modules expose complexity without providing corresponding benefit.

**Taking it too far:** Obsessing over depth at the expense of clarity. Some modules are naturally shallow (e.g., a method that delegates to a slightly lower-level method). That's acceptable if the module serves an important abstraction boundary.

**Example:** Unix I/O interface (five basic calls: `open`, `read`, `write`, `close`, `lseek`) vs Java I/O (dozens of classes). Unix I/O is deep — the interface is far simpler than the implementation.

---

## 3. Information Hiding

**Book reference:** Ch 5

**Core idea:** Each module should hide a few design decisions from the rest of the system. The interface reveals as little as possible about the module's internals. This allows implementation changes without affecting callers.

**Why it reduces complexity:** Reduces change amplification (internal changes don't affect callers) and unknown unknowns (callers don't need to know about internals).

**Taking it too far:** Over-hiding makes it impossible to test, debug, or subclass the module. If you can't write a unit test without exposing internals, you've hidden too much.

**Example:** A `Request` class should not reveal in its interface whether it uses `urllib.parse`, regex, or custom parsing. That's an implementation detail.

---

## 4. Information Leakage

**Book reference:** Ch 5

**Core idea:** The opposite of information hiding. Information leakage occurs when the same design knowledge is reflected in multiple modules. Changes to that knowledge require changes in all affected modules.

**Why it increases complexity:** Creates change amplification (one conceptual change requires edits everywhere) and unknown unknowns (you might not know which modules share the leaked information).

**Red flag:** Information Leakage — the most important red flag in the book.

**Fix:** Consolidate the leaked knowledge into a single module, or re-encapsulate so the knowledge only affects one module.

**Taking it too far:** Over-consolidation — merging unrelated concepts just because they reference the same external entity. Not all shared information belongs in the same module. Use the "change together, stay together" heuristic: merge only if they change for the same reason.

---

## 5. General-Purpose Modules Are Deeper

**Book reference:** Ch 6

**Core idea:** Modules designed to be slightly more general-purpose than the current need tend to have deeper interfaces. They serve multiple use cases without interface changes.

**Why it reduces complexity:** A general-purpose module is reused, not duplicated. Its interface is stable because it wasn't designed for one specific caller.

**Diagnostic questions:**
- "In how many situations will this method be used?" (If one, it may be too special-purpose.)
- "Is this API easy to use for my current needs?" (If not, redesign.)
- "Can I replace several special-purpose methods with a single general-purpose method?"

**Taking it too far:** Over-generalization leads to complex interfaces that try to serve every possible future need. Design for known needs with some extension margin; don't design for hypotheticals.

---

## 6. Different Layer, Different Abstraction

**Book reference:** Ch 7

**Core idea:** Each software layer should provide a different abstraction from the layers above and below. If adjacent layers have similar abstractions, one of them isn't adding value.

**Why it reduces complexity:** Eliminates pass-through methods and pass-through variables, which increase cognitive load without providing benefit.

**Red flags:**
- **Pass-Through Method** — A method that does nothing but call another method with the same signature. Eliminate it.
- **Pass-Through Variables** — A variable threaded through multiple methods that don't use it, just to pass it to a deeper method. Use a shared context object instead.

**Taking it too far:** Some interface duplication between layers is acceptable (e.g., a facade that delegates to a subsystem). The key is whether each layer provides meaningful abstraction.

---

## 7. Pull Complexity Downward

**Book reference:** Ch 8

**Core idea:** When a feature has inherent complexity, handle that complexity in the module's implementation rather than exposing it through the interface. Make the common case simple for callers.

**Why it reduces complexity:** Reduces cognitive load for callers. They interact with a simple interface; the complexity is hidden inside the module.

**Taking it too far:** The module grows into a god class that knows about everything. Its interface is simple, but its implementation is a tangled web of interrelated functionality.

**Example:** Text editor undo. Instead of returning undo actions to the caller (pushing complexity upward), manage the undo stack inside the text module.

---

## 8. Better Together or Better Apart

**Book reference:** Ch 9

**Core idea:** A decision framework for whether to split or merge modules:

**Bring together if:**
- Information is shared between them
- Merging simplifies the overall interface
- Merging eliminates duplication

**Keep separate if:**
- One is general-purpose and the other is special-purpose
- They address different abstraction levels

**Red flag:** Conjoined Methods — if you can't understand one method without understanding another, they shouldn't have been split.

**Taking it too far:** Over-merging creates god classes. If a module has multiple distinct responsibilities that could change independently, they should have been split. Merge what changes together; keep separate what changes separately.

---

## 9. Define Errors Out of Existence

**Book reference:** Ch 10

**Core idea:** The best way to handle errors is to design interfaces so that common errors can't occur. This is better than checking for errors at runtime.

**Techniques:**
1. **Eliminate** — Change the interface contract so the error case doesn't exist (e.g., `delete_file` succeeds if the file doesn't exist, rather than raising an error)
2. **Mask** — Handle the exception at the right level so callers don't see it
3. **Aggregate** — Replace many exception types with one
4. **Crash** — If recovery is meaningless, don't force callers to handle it

**Taking it too far:** Crashing when recovery is possible and meaningful. The "just crash" approach should only be used for errors where no reasonable recovery exists.

**Example:** Windows file deletion — if the file is open, Windows marks it for deletion and removes it when closed, rather than refusing to delete it.

---

## 10. Design It Twice

**Book reference:** Ch 11

**Core idea:** Never accept the first design for a non-trivial component. Create at least two alternative designs, list their tradeoffs, and pick the best. The second design is often significantly better.

**Why it reduces complexity:** The first design is usually tactical — it follows the obvious path. Designing a second alternative forces you to consider different tradeoffs and often reveals a better, deeper design.

**Example:** Text class for an editor. First approach: line-oriented (complex interface, line-splitting logic exposed). Second approach: character-oriented (too low-level, callers need loops). Third approach: range-oriented (deep — simple interface, powerful operations on character ranges).

**Taking it too far:** Analysis paralysis. Comparing more than 2-3 designs without deciding wastes time. The goal is better design, not perfect design. If you have evidence the first design is sound and the alternatives don't offer clear improvement, proceed with the best option.

---

## 11. Comments Describe Non-Obvious

**Book reference:** Ch 12-13

**Core idea:** Comments should describe things that aren't obvious from reading the code. This includes design rationale, high-level structure, cross-module decisions, and anything counterintuitive.

**Two types:**
- **Interface comments:** For callers — describe what the method does, the contract, and the abstraction. Not how it's implemented.
- **Implementation comments:** For maintainers — describe why a particular approach was chosen, not what the code does (which is obvious from the code itself).

**Red flags:**
- Comment repeats code — the comment adds no information
- Implementation docs contaminate interface — interface comments reveal implementation details
- Hard to describe — if documentation must be long, the design is too complex

**Why it reduces complexity:** Reduces unknown unknowns — future maintainers understand the rationale behind code, not just the mechanics.

**Taking it too far:** Over-documenting the obvious. If every line has a comment, the signal-to-noise ratio drops and comments are ignored. Only comment where the code alone is insufficient — the code should speak for itself wherever possible.

---

## 12. Comments First

**Book reference:** Ch 15

**Core idea:** Write the interface comment before writing the implementation body. If the comment is hard to write, the design is wrong. If the comment is long, the design is probably wrong.

**Why it reduces complexity:** Forces you to design the interface before getting lost in implementation details. Hard-to-write comments reveal design problems early.

**Taking it too far:** Writing detailed interface comments before the design is stable. Premature commenting locks in a design before it's validated. Comments-first works best when you have a clear concept; iterate the concept first, then document the stable interface.

---

## 13. Choosing Names

**Book reference:** Ch 14

**Core idea:** Names should "create an image" — a precise, intuitive mental picture of the concept being named. If you can't find a good name, you don't understand the concept well enough.

**Red flags:**
- **Vague Name** — The name is too imprecise to convey meaning
- **Hard to Pick Name** — If you can't name it, redesign
- **Extra Words** — Names should have no unnecessary words

**Why it reduces complexity:** Good names make code obvious. Bad names force readers to decode meaning.

**Taking it too far:** Overly long names that try to capture every nuance. The name should create an image, not serve as full documentation. "Descriptive enough to distinguish, short enough to read" — if the name alone can't convey everything, that's what the comment is for.

---

## 14. Modifying Existing Code

**Book reference:** Ch 16

**Core idea:** Stay strategic even during modifications. Every change is an opportunity to improve the design of surrounding code. Keep comments near the code they describe. Document decisions in code comments, not commit messages.

**Why it reduces complexity:** Prevents design rot during maintenance. Higher-level comments (module purpose, design rationale) are much easier to maintain than line-by-line explanations.

**Taking it too far:** Over-refactoring — rewriting working code to match an ideal, creating risk without commensurate benefit. The strategic approach to modification should focus on areas that actually reduce complexity, not cosmetic improvements.

---

## 15. Consistency

**Book reference:** Ch 17

**Core idea:** Use consistent conventions for naming, patterns, formatting, and behavior. Consistency reduces cognitive load — once a reader learns a pattern, they can apply it everywhere.

**Taking it too far:** Dogmatic consistency that ignores context. The consistent approach can be actively wrong for a specific case. Use judgment.

---

## 16. Code Should Be Obvious

**Book reference:** Ch 18

**Core idea:** If someone needs to think hard to understand what code does, the code is not obvious. Nonobvious code is a design problem, not a documentation problem. Redesign rather than explain.

**Obviousness test:** "If someone else reads this and needs to think hard to understand it, the code is not obvious." Run this before marking any code complete.

**Taking it too far:** Oversimplification that obscures important behavior. Sometimes subtle code is necessary for performance, correctness, or concurrency. Not everything can be obvious at first glance; the goal is to *minimize* nonobvious code, not eliminate it entirely.

---

## 17. Design for the Future

**Book reference:** Ch 21

**Core idea:** Identify what's likely to change and what's stable. Encapsulate the volatile parts. Don't add hooks or configurability for hypothetical futures — only for changes you have reasonable evidence will occur.

**Techniques:**
- Emphasize what matters and hide what doesn't
- Delete what's no longer needed
- Prefer deletion over extension

**Taking it too far:** Over-engineering for hypothetical futures. Adding hooks, configurability, or abstraction layers for scenarios that have no evidence of occurring. Design for known changes with extension margin; don't design for guesses.

---

## 18. Performance as Design

**Book reference:** Ch 20

**Core idea:** Design-level decisions (module boundaries, data structures, communication patterns) have a far greater impact on performance than micro-optimizations. Clean designs are easier to profile and optimize.

**Never:** Sacrifice design clarity for speculative performance gains.

**Instead:** Measure before optimizing. Clean designs reveal performance bottlenecks more clearly than tangled ones.

**Taking it too far:** Distorting module boundaries for speculative optimization. Clean design enables optimization — you can always optimize later once profiling identifies real bottlenecks. Never trade design clarity for unmeasured performance gains.

---

## 19. Increments Are Abstractions, Not Features

**Book reference:** Ch 3, 22

**Core idea:** Decompose development tasks by abstraction boundary, not by feature. A new feature should be implemented as "create the abstraction layer" first, then "build the feature on top of it." Don't decompose by execution order or UI surface area.

**Example:** "Add text formatting toolbar" → implement the formatting interface (deep module), then build the toolbar UI on top of it. Not: "add bold button, then italic button, then underline button."

**Taking it too far:** Creating abstractions without concrete use cases. Increments should be guided by actual feature needs, not abstractions designed in a vacuum. The abstraction is a means to reduce complexity for real features, not an end in itself.

---

## Software Trends Awareness

**Book reference:** Ch 19

The book critiques several common trends:
- **Classitis** — OOP's tendency to create too many shallow classes. Not every concept needs its own class.
- **TDD over-emphasis** — Unit tests verify behavior but don't ensure good design. Design quality is separate from test coverage.
- **Agile's short-term focus** — Iterations should not excuse tactical programming. Each iteration should produce well-designed code.

When a "standard practice" conflicts with complexity reduction, favor the complexity lens.

---

## Taking It Too Far (Summary)

| Principle | Limit | Signal |
|-----------|-------|--------|
| Information hiding | Can't test or subclass | Must expose internals for unit tests |
| Consistency | Ignores context | Consistent approach is actively wrong here |
| Pull complexity downward | God class | Module knows about everything |
| Define errors out of existence | Crash when recovery possible | Error could be handled at higher level |
| Design for the future | Over-engineering | Hooks for scenarios that never occurred |
