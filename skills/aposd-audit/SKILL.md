---
name: aposd-audit
description: Use when you need a systematic audit of code design quality with scored dimensions and tactical tornado risk assessment. Checks module design, information hiding, comments, naming, consistency, and obviousness.
license: MIT
---

# aposd audit — Design Quality Audit

Run systematic design quality checks and generate a comprehensive report. Don't fix issues; document them for review.

This is a code-level design audit, not a feature review. Check what's measurable and verifiable in the implementation.

## Diagnostic Scan

Run comprehensive checks across 5 dimensions. Score each dimension 0-4 using the criteria below.

### 1. Module Design

**Check for:**
- **Deep vs shallow**: Does the interface add abstraction beyond the implementation? Count shallow modules (interface as complex as implementation).
- **Pass-through methods**: Methods that do nothing except call another method with the same signature.
- **Pass-through variables**: Configuration/context threaded through multiple methods that don't use it.
- **Temporal decomposition**: Code structure that mirrors execution order instead of hiding information.
- **God classes**: Modules that know about everything — they have simple interfaces but tangled implementations.

**Score 0-4**: 0=Fundamental problems (pervasive pass-throughs, temporal decomposition everywhere), 1=Major issues (multiple shallow modules, significant pass-through chains), 2=Partial (some deep modules, but several shallow ones), 3=Good (mostly deep modules, isolated shallow spots), 4=Excellent (all modules are deep, clear boundaries, no pass-throughs)

### 2. Information Hiding

**Check for:**
- **Information leakage**: The same design knowledge reflected in multiple modules (URLs, business rules, data formats).
- **Overexposure**: APIs that force callers to learn rarely-used features to use common ones.
- **Interface contamination**: Implementation details visible in interface comments or method signatures.
- **General-purpose mixture**: Special-purpose logic mixed into general-purpose modules.

**Score 0-4**: 0=Widespread leakage (same knowledge in 5+ places), 1=Major leakage (multiple cross-module dependencies), 2=Partial (some leakage, isolated), 3=Good (minor leakage, mostly clean boundaries), 4=Excellent (clean information hiding, no leakage)

### 3. Comments & Documentation

**Check for:**
- **Missing interface comments**: Public methods without documentation of contract.
- **Comment repeats code**: Comments that add no information beyond what's obvious.
- **Implementation docs in interfaces**: Interface comments that reveal how something works, not what it does.
- **Hard to describe**: Methods whose behavior requires long documentation to explain.
- **Stale comments**: Comments that contradict the code they describe.

**Score 0-4**: 0=No documentation (no interface comments anywhere), 1=Minimal docs (some comments, mostly repeats code or stale), 2=Partial (interfaces documented, no design rationale), 3=Good (clear interface comments, some design rationale), 4=Excellent (comments-first approach, interface + implementation docs, design decisions documented)

### 4. Naming & Obviousness

**Check for:**
- **Vague names**: Identifiers too imprecise to convey meaning (`data`, `info`, `process`, `handle`, `tmp`).
- **Hard to name**: Evidence that concepts weren't well-understood (unclear abstractions, shifting names).
- **Nonobvious code**: Code that requires significant mental effort to understand.
- **Special cases**: Logic for edge cases that could be eliminated by better design.
- **Inconsistent naming**: Same concept named differently in different places.

**Score 0-4**: 0=Opaque (pervasive vague names, code requires deep analysis to understand), 1=Poor (many unclear names, nonobvious logic), 2=Partial (mostly clear names, some nonobvious sections), 3=Good (clear names, code is obvious with minimal effort), 4=Excellent (names create an image, code is obvious at first read, no special cases)

### 5. Error Strategy

**Check for:**
- **Error elimination**: Could the interface be redesigned to make common errors impossible?
- **Too many exceptions**: Does every possible error have its own exception type?
- **Error-handling duplication**: Does error-handling code mirror the happy path?
- **Masking level**: Are exceptions masked at the right abstraction level?
- **Crash vs recover**: Are errors that could be recovered from being swallowed or causing crashes?

**Score 0-4**: 0=Error chaos (errors propagated everywhere, no strategy), 1=Poor (too many exception types, error handling doubles code), 2=Partial (some error consolidation, but ad-hoc approach), 3=Good (clear error strategy, errors defined out of existence where practical), 4=Excellent (interfaces designed to prevent errors, minimal and meaningful exception types)

## Generate Report

### Design Health Score

Score 5 dimensions 0-4 (see `reference/scoring.md` for full rubric):

| # | Dimension | Score | Key Finding |
|---|-----------|-------|-------------|
| 1 | Module Design | ? | |
| 2 | Information Hiding | ? | |
| 3 | Comments & Documentation | ? | |
| 4 | Naming & Obviousness | ? | |
| 5 | Error Strategy | ? | |
| **Total** | | **??/20** | **[Rating band]** |

### Tactical Tornado Risk

See `reference/scoring.md` for risk levels. Assess: **Low / Medium / High** based on red flag patterns found.

### Executive Summary
- Design Health Score: **??/20** ([rating band])
- Tactical Tornado Risk: **[Low / Medium / High]**
- Total issues found (count by severity: Critical/Major/Minor)
- Top 3-5 critical issues
- Recommended next steps

### Detailed Findings by Severity

Tag every issue with severity:
- **Critical**: Fundamental design problem. Redesign required. Creates unknown unknowns.
- **Major**: Significant complexity increase. Should be fixed. Creates cognitive load or change amplification.
- **Minor**: Localized issue. Worth fixing when in the area.

For each issue, document:
- **[Critical/Major/Minor] Issue name**
- **Location**: Component, file, line
- **Category**: Module Design / Information Hiding / Comments / Naming / Error Strategy
- **Complexity symptom**: Change amplification / Cognitive load / Unknown unknowns
- **Impact**: How it affects future development
- **Recommendation**: APOSD-aligned fix

### Patterns & Systemic Issues

Identify recurring problems that indicate systemic gaps rather than one-off mistakes:
- "Pass-through methods appear in every service layer class"
- "Information leakage pattern: the same business rule is embedded in 6 different files"

### Positive Findings

Note what's working well: good practices to maintain and replicate. Deep modules, clean information hiding, good interface comments — celebrate these.

## Recommended Actions

List recommended actions in priority order (Critical first, then Major, then Minor):

1. **[Critical/Major/Minor]**: Brief description (specific context from audit findings)
2. ...

After presenting the summary, tell the user:

> You can ask me to address these one at a time, all at once, or in any order you prefer.
>
> Re-run `aposd audit` after fixes to see your score improve.

**IMPORTANT**: Be thorough but actionable. Too many Minor issues creates noise. Focus on what actually matters.

**NEVER**:
- Report issues without explaining complexity impact (which symptom does this cause?)
- Provide generic recommendations (be specific and actionable)
- Skip positive findings (celebrate what works)
- Forget to prioritize (everything can't be Critical)
- Report false positives without verification
