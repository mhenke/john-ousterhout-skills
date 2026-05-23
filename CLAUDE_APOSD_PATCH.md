APOSD Merge Patch for CLAUDE.md

Purpose

This file contains the APOSD addendum and exact insertion recommendations for CLAUDE.md. Because the repository's CLAUDE.md was not read (permission to read repo files was not used), this patch is provided as a ready-to-paste block for maintainers to insert at the appropriate location (e.g., a new header "APOSD Principles and Reviewer Guidance").

Suggested insertion point:
- Insert after the high-level "Principles" or "Design" section in CLAUDE.md, or append near the end under a new top-level header.

--- BEGIN APOSD ADDENDUM (paste below into CLAUDE.md) ---

## APOSD Principles and Reviewer Guidance (Ousterhout)

This section presents concise, actionable guidance derived from John Ousterhout's "A Philosophy of Software Design" and an APOSD-oriented reading of the APOSD vs Clean Code dialog.

Principles

- Design Deep Modules: Prefer methods that present a small, powerful interface that replaces in-head implementation detail.
- Information Hiding: Hide internal state and complexity; expose minimal, well-named behavior.
- Push Complexity Downward: Let callers use simple interfaces; move complexity into implementations.
- Comments-First for Design: Use short, high-level comments to explain intent and rationale; prefer English "why" comments for design-level decisions.
- Define Errors Out of Existence: Change interfaces to avoid common errors when possible.

APOSD Reviewer Checklist (brief)

1. Does this method reduce the amount of information a reader must hold to use it? If yes, prefer keeping it "deep".
2. Does extracting a tiny method increase cross-referencing (chasing names) without reducing mental load? If yes, prefer consolidation.
3. Are English comments explaining design-level intent present where abstractions alone won't convey rationale? If not, request a short "why" comment.
4. Are error cases handled by interface design rather than ad-hoc checks? If not, suggest interface changes.

Reviewer prompt examples

- "APOSD: This method is compact and returns a clear abstraction; consider documenting the intended invariants rather than extracting further helpers."
- "APOSD: Extraction here increases call-site hopping; can the logic be consolidated into a single well-named helper with an explanatory comment?"

Teaching anchors

- Use the PrimeGenerator2 example (Ousterhout's deeper-method rewrite) as a canonical teaching example that demonstrates when a deeper method is preferable to many tiny helpers.

--- END APOSD ADDENDUM ---

Notes

- After inserting this block, consider adding a one-line TOC entry linking to the new section.
- If desired, we can prepare a small PR that edits CLAUDE.md directly; provide write permission or confirm the exact insertion point and I will generate a patch file (diff) ready to apply.
