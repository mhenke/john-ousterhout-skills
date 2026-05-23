APOSD Addendum for CLAUDE.md

Purpose

This addendum captures APOSD-first guidance distilled from John Ousterhout's work and the APOSD vs Clean Code discussion. It is intended to be merged into CLAUDE.md as the APOSD Principles and Reviewer Guidance section.

APOSD Principles (short)

- Design Deep Modules: Prefer methods that present a small, powerful interface that replaces in-head implementation detail.
- Information Hiding: Hide internal state and complexity; expose minimal, well-named behavior.
- Push Complexity Downward: Let callers use simple interfaces; move complexity into implementations.
- Comments-First for Design: Use short, high-level comments to explain intent and rationale; prefer English "why" comments for design-level decisions.
- Define Errors Out of Existence: Change interfaces to avoid common errors when possible.

Reviewer Checklist (APOSD-focused)

1. Does this method reduce the amount of information a reader must hold to use it? If yes, prefer keeping it "deep".
2. Does extracting a tiny method increase cross-referencing (chasing names) without reducing mental load? If yes, prefer consolidation.
3. Are English comments explaining design-level intent present where abstractions alone won't convey rationale? If not, request a short "why" comment.
4. Are error cases handled by interface design rather than ad-hoc checks? If not, suggest interface changes.

Short Reviewer Prompts (example comments)

- "This method is compact and returns a clear abstraction; consider documenting the intended invariants rather than extracting further helpers."
- "Extraction here increases call-site hopping; can the logic be consolidated into a single well-named helper with an explanatory comment?"

Examples and Teaching Anchors

- Refer to the PrimeGenerator examples (Ousterhout's deeper-method rewrite) as canonical APOSD examples. Provide links in the main CLAUDE.md to the examples/prime-generator/aposd folder (added in Phase B).

Footnotes

- Primary source: johnousterhout/aposd-vs-clean-code README (discussion and PrimeGenerator examples) — see repository for full citations.

Implementation note

This addendum is intended to be merged into CLAUDE.md (append or merge). It is provided here as a repository file for review and commit.
