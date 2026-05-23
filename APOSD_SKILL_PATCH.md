APOSD Skill Merge Patch for skills/aposd/SKILL.md

Purpose

Provides the APOSD skill addendum text and recommended short rubric for insertion into skills/aposd/SKILL.md or the skill's guidance files (.cursor rules).

--- BEGIN APOSD SKILL ADDENDUM (paste into skills/aposd/SKILL.md) ---

APOSD Skill: Behavior and Reviewer Rubric

When the APOSD skill is active it should prioritize these checks and recommendations:

1) Deep-module detection: Prefer keeping methods that provide a compact, powerful interface rather than splitting into many trivial helpers that increase cognitive hopping.
2) Comment recommendation: If an abstraction's "why" is not obvious, request a 1-3 line English comment explaining rationale and invariants.
3) Interface-driven error handling: Suggest interface changes that eliminate common error cases rather than sprinkling ad-hoc checks.

Reviewer Rubric (3 quick questions)

- Does the abstraction reduce working memory required to perform common tasks? (Yes → keep deep)
- Would a short English comment at the top of this function help a reader understand the design tradeoff? (Yes → request comment)
- Can common error cases be eliminated by changing the interface? (Yes → suggest interface change)

Suggested short automated prompts

- "APOSD-check: Consider consolidating these tiny helpers into a single well-documented interface."
- "APOSD-check: Add a 1-3 line design comment explaining why this decomposition is necessary."

Teaching anchor

- Reference the PrimeGenerator2 example in the examples/prime-generator/aposd folder (Phase B). Use this example when explaining deep-module heuristics to contributors.

--- END APOSD SKILL ADDENDUM ---

Notes

- This patch is provided as a ready-to-paste block. If granted permission to edit skills/aposd/SKILL.md directly, a follow-up can create a PR that inserts these sections and updates .cursor rules automatically.
