# ADR-008: Declined Safeguards — CI, Validation, Supply Chain

**Date:** 2026-05-24
**Status:** Accepted
**Applies to:** Project-wide

## Context

The comprehensive review (2026-05-24) identified several findings in the High range that recommend adding validation, testing, and security infrastructure:

1. **H01 — No automated tests or validation** — No test files, no CI pipeline, no frontmatter or cross-file consistency checks.
2. **T02 — No frontmatter validation for skill files** — SKILL.md frontmatter (name, description, license) has no schema validation.
3. **SE01 — No integrity verification for downloaded skills** — README install examples use `curl` without checksums or signature verification.
4. **SE02 — No supply chain security** — Plugin has no SBOM, dependency pinning, or integrity hashes for published versions.
5. **A03 — Agent definition not exposed through plugin system** — `agents/aposd-agent.md` exists but isn't linked from plugin manifest.

Each of these is a valid concern. Each would require either a CI pipeline, a build step, or a distribution infrastructure change to address.

## Decision

We decline to implement any of these five safeguards. The project will remain a collection of static markdown files distributed via git, with no CI, no build step, and no automated validation.

## Rationale

- **CI is not worth the setup cost.** A sync script or validation pipeline for a project with ~20 markdown files and one maintainer would be maintained longer than it saves. ADR-005 (clause 3) already established this principle for the 3-way rule sync — it applies equally here.
- **Supply chain security assumes a distribution model we don't have.** The project distributes via `git clone` or `curl` from GitHub. A consumer who trusts GitHub's TLS and their own `git verify-commit` setup already has the security model this project would offer. Adding checksums or SBOMs would add process without meaningfully changing the threat model for a project of this size.
- **Frontmatter validation without CI is just a script.** A local `validate.sh` that checks frontmatter would catch errors, but would run only when the maintainer remembers to run it — the same human-discipline failure mode ADR-005 accepted. Not worth the scaffolding.
- **Agent definition exposure** is premature. The `agents/aposd-agent.md` file documents a behavioral profile that isn't ready for distribution. If it matures into a distributable artifact, the plugin manifest should be updated then — not now with an empty structure.
- **Every safeguard adds maintenance surface.** Each check, each script, each CI config line is code that can break, drift, or need updates. For a project this size, the cost exceeds the benefit.

## Consequences

- Consumers who `curl` files from GitHub accept the existing TLS trust model.
- Contributors must manually validate changes (reading diffs, checking frontmatter by eye).
- No automated guard prevents a broken SKILL.md from being committed.
- The `agents/aposd-agent.md` file remains a design artifact, not a distributable asset.
- This decision can be revisited if the project gains additional maintainers, a formal release process beyond git tags, or evidence that the lack of safeguards causes real downstream issues.
