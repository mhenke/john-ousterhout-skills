APOSD Skill Addendum (for skills/aposd/SKILL.md)

Objective

Provide a concise skill-level checklist and reviewer rubric that prioritizes APOSD principles for code review agents and human reviewers.

Skill Behavior (short)

- When activated, the APOSD skill should: (1) Check for deep-module opportunities, (2) Flag excessive tiny-method extraction that increases cognitive hopping, (3) Recommend design-level comments when abstractions don't capture rationale.

Reviewer Rubric (3 questions)

1. "Does the abstraction reduce working memory required to perform common tasks?" (Yes → keep deep)
2. "Would a short English comment at the top of this function help a reader understand the design tradeoff?" (Yes → request comment)
3. "Can common error cases be eliminated by changing the interface?" (Yes → suggest interface change)

Suggested automated prompts (for reviewers/agents)

- "APOSD check: prefer consolidating these tiny helper methods into a single interface that documents invariants."
- "APOSD check: add a 1-3 line design comment explaining why this decomposition exists or why it is avoided."

Teaching Example: PrimeGenerator2 (Ousterhout)

- Include the Ousterhout PrimeGenerator2 code as the canonical APOSD example in examples/prime-generator/aposd (Phase B). The skill should reference that example when explaining "deep module" heuristics.

Short integration note

- This addendum should be merged into skills/aposd/SKILL.md. For Phase A we provide this as a repository file for review and later commit.