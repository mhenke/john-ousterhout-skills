---
name: aposd-review
description: Use when you need to scan code for design red flags from "A Philosophy of Software Design" by John Ousterhout. Detects shallow modules, information leakage, pass-through methods, temporal decomposition, and other design problems.
license: MIT
---

# aposd review — Red Flag Scan

Scans code for design red flags from *A Philosophy of Software Design, 2nd Edition* (Ousterhout, 2021).

**Usage:** `aposd review [file path, code block, or module name]`

## Process

Evaluate the target against each red flag in priority order. For each red flag found, report: location, why it increases complexity, and a suggested APOSD-aligned fix.

## Red Flags (Priority Order)

1. **Information Leakage** — The same design decision appears in multiple modules. Consolidate or re-encapsulate.

2. **Shallow Module** — The interface is as complex as the implementation. Merge with another module or redesign for depth.

3. **Temporal Decomposition** — Code structure mirrors execution order instead of information hiding. Redesign around abstractions, not steps.

4. **Pass-Through Method** — A method that does nothing except call another method with the same signature. Eliminate the middleman.

5. **Pass-Through Variables** — A variable threaded through multiple layers of method calls that don't use it. Use a shared context or global.

6. **Repetition** — The same nontrivial code appears in multiple places. Extract into a shared module.

7. **Special-General Mixture** — General-purpose code contains special-purpose logic. Separate them.

8. **Conjoined Methods** — You can't understand one method without understanding another. Merge them or clarify the boundary.

9. **Overexposure** — The API forces callers to learn rarely-used features to use common features. Split the interface.

10. **Comment Repeats Code** — The comment adds no information beyond what's obvious from the code. Remove it or add insight.

11. **Implementation Docs Contaminate Interface** — Interface documentation describes implementation details. Strip them.

12. **Vague Name** — The name is too imprecise to convey meaning. Rename to create an image.

13. **Hard to Pick Name** — You can't find an intuitive name. You don't understand the concept well enough — redesign.

14. **Hard to Describe** — The documentation must be long to be complete. The design is too complex — simplify.

15. **Nonobvious Code** — Someone would need to think hard to understand what this code does. Redesign for clarity.

## Output

- Red flags found (ordered by severity): location, complexity symptom, suggested fix
- Design score 1-5
- Top 3 improvements ranked by complexity reduction potential
- Final question: "Is this module deep enough? Does it hide complexity or expose it?"
