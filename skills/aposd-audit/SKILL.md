---
name: aposd-audit
description: Use when you need a systematic scored evaluation of design quality across multiple dimensions. Also use before major refactoring to identify which areas need the most attention, or when code shows red flags like shallow modules, information leakage, and pass-through methods.
license: MIT
---

# aposd audit — Design Quality Audit

Run systematic design quality checks and generate a comprehensive report. Don't fix issues; document them for review.

This is a code-level design audit, not a feature review. Check what's measurable and verifiable in the implementation.

**Scoring rubric:** See `reference/scoring.md` for full dimension definitions, per-score meanings, and rating bands.

**Example output for a shallow class:**
```
Module Design: 2/4 — shallow pass-through
Information Hiding: 3/4 — schema leaked through methods
Tactical Tornado Risk: High
Total: 9/20 (Needs work)
Action: Consolidate find_by_* into find(**filters)
```

## Setup

Before starting the audit, resolve the target to a concrete file path, directory, or module name. If no target is specified, default to the current workspace root directory.

**Resolution anchoring:** Before scoring, read `reference/scoring.md` for the rubric. For each dimension, identify the rubric criterion that describes the code and find specific code evidence (file:line:pattern) that demonstrates it. Every score point must cite both the rubric criterion and the code evidence.

**Scope scoping:** If the target has more than 15 files, sample systematically (first/middle/last of each directory group). Report the sample scope in the report: "Sampled 8/24 files in src/services/."

## Diagnostic Scan

Run comprehensive checks across 5 dimensions. Score each dimension 0-4 using the criteria below.

### 1. Module Design

**Check for:**
- **Deep vs shallow**: Does the interface add abstraction beyond the implementation? Count shallow modules (interface as complex as implementation).
- **Pass-through methods**: Methods that do nothing except call another method with the same signature.
- **Pass-through variables**: Configuration/context threaded through multiple methods that don't use it.
- **Temporal decomposition**: Code structure that mirrors execution order instead of hiding information.
- **God classes**: Modules that know about everything — they have simple interfaces but tangled implementations.

**Score 0-4**: 0=5+ shallow modules OR 3+ pass-through chains OR pervasive temporal decomposition, 1=3-4 shallow modules OR 2 pass-through chains OR any god class, 2=1-2 shallow modules OR 1 pass-through chain, 3=0 shallow modules, isolated pass-through method (not a chain), 4=All modules deep, no pass-throughs, clear boundaries

### 2. Information Hiding

**Check for:**
- **Information leakage**: The same design knowledge reflected in multiple modules (URLs, business rules, data formats).
- **Overexposure**: APIs that force callers to learn rarely-used features to use common ones.
- **Interface contamination**: Implementation details visible in interface comments or method signatures.
- **General-purpose mixture**: Special-purpose logic mixed into general-purpose modules.

**Score 0-4**: 0=Same knowledge in 5+ places OR 3+ cross-module leakages, 1=2-4 cross-module leakages OR any interface contamination, 2=1-2 isolated leakages, 3=Minor leakage (1 instance, limited scope), 4=No leakage, clean boundaries

### 3. Comments & Documentation

**Check for:**
- **Missing interface comments**: Public methods without documentation of contract.
- **Comment repeats code**: Comments that add no information beyond what's obvious.
- **Implementation docs in interfaces**: Interface comments that reveal how something works, not what it does.
- **Hard to describe**: Methods whose behavior requires long documentation to explain.
- **Stale comments**: Comments that contradict the code they describe.

**Score 0-4**: 0=No interface comments on public methods OR all comments stale, 1=<25% of public methods documented OR most comments repeat the code, 2=25-75% of public methods documented, no design rationale, 3=>75% documented, clear interface comments, some design rationale, 4=All public methods have interface comments, design decisions documented, comments-first approach

### 4. Naming & Obviousness

**Check for:**
- **Vague names**: Identifiers too imprecise to convey meaning (`data`, `info`, `process`, `handle`, `tmp`).
- **Hard to name**: Evidence that concepts weren't well-understood (unclear abstractions, shifting names).
- **Nonobvious code**: Code that requires significant mental effort to understand.
- **Special cases**: Logic for edge cases that could be eliminated by better design.
- **Inconsistent naming**: Same concept named differently in different places.

**Score 0-4**: 0=5+ vague names OR any module requires deep analysis to understand, 1=3-4 vague names OR 2+ nonobvious code sections OR 2+ special cases, 2=1-2 vague names OR 1 nonobvious section OR 1 special case, 3=All names clear, code obvious with minimal effort, 0 special cases, 4=Names create an image, code obvious at first read, no special cases

### 5. Error Strategy

**Check for:**
- **Error elimination**: Could the interface be redesigned to make common errors impossible?
- **Too many exceptions**: Does every possible error have its own exception type?
- **Error-handling duplication**: Does error-handling code mirror the happy path?
- **Masking level**: Are exceptions masked at the right abstraction level?
- **Crash vs recover**: Are errors that could be recovered from being swallowed or causing crashes?

**Score 0-4**: 0=No error strategy OR error handling duplicates happy path in 3+ places, 1=5+ exception types OR error handling doubles code in 2+ places, 2=Some error consolidation but ad-hoc (1-2 places where errors could be eliminated), 3=Clear error strategy, errors defined out of existence where practical, 4=Interfaces designed to prevent errors, minimal exception types, clean masking at right level

## Generate Report

### Design Health Score

Score 5 dimensions 0-4 (see `reference/scoring.md` for full rubric). Every score must cite both the rubric criterion and the code evidence:

| # | Dimension | Score | Key Finding | Evidence |
|---|-----------|-------|-------------|----------|
| 1 | Module Design | ? | | Rubric criterion quoted. File:line:pattern cited. |
| 2 | Information Hiding | ? | | Rubric criterion quoted. File:line:pattern cited. |
| 3 | Comments & Documentation | ? | | Rubric criterion quoted. File:line:pattern cited. |
| 4 | Naming & Obviousness | ? | | Rubric criterion quoted. File:line:pattern cited. |
| 5 | Error Strategy | ? | | Rubric criterion quoted. File:line:pattern cited. |
| **Total** | | **??/20** | **[Rating band]** |

### Tactical Tornado Risk

See `reference/scoring.md` for risk levels. Assess: **Low / Medium / High** based on red flag counts found. Must cite the count:

> **Tactical Tornado Risk: HIGH** (7 red flags: 2 information leakage, 3 shallow modules, 2 pass-throughs). Rubric: "High = Pervasive shallow modules, leaky abstractions, pass-through chains."

### Executive Summary
- Design Health Score: **??/20** ([rating band])
- Tactical Tornado Risk: **[Low / Medium / High]**
- Total issues found (count by severity: Critical/Major/Minor)
- Top 3-5 critical issues
- Recommended next steps

> **Note:** Scores are based on evidence found at the reported locations. If the same code is re-run without changes, the same evidence produces the same score. Fix the findings to change the score.

### Detailed Findings by Severity

Every finding must pass the Specificity Validation Gate before being reported. Tag every issue with severity:
- **Critical**: Fundamental design problem. Redesign required. Creates unknown unknowns.
- **Major**: Significant complexity increase. Should be fixed. Creates cognitive load or change amplification.
- **Minor**: Localized issue. Worth fixing when in the area.

For each issue, document:
- **[Critical/Major/Minor] Issue name**
- **Location**: Component, file, line
- **Dimension**: Module Design / Information Hiding / Comments / Naming / Error Strategy
- **Complexity symptom**: Change amplification / Cognitive load / Unknown unknowns
- **Impact**: How it affects future development
- **Recommendation**: APOSD-aligned fix (must be a concrete action, not a suggestion)

### Patterns & Systemic Issues

Identify recurring problems that indicate systemic gaps rather than one-off mistakes:
- "Pass-through methods appear in every service layer class"
- "Information leakage pattern: the same business rule is embedded in 6 different files"

### Positive Findings

Note what's working well: identify design strengths that actively prevent complexity (e.g., deep modules, clean information hiding, interface comments). Be objective rather than congratulatory; explain precisely why they reduce cognitive load or change amplification.

### Specificity Validation Gate

Before reporting any finding, self-validate against this checklist:

```
□ File path (absolute or relative to target)
□ Line number(s)
□ Code pattern (exact snippet, 1-3 lines)
□ Complexity symptom (change amplification / cognitive load / unknown unknowns)
□ Concrete fix (an action — "extract into UserRepository.find()" not "consider refactoring")
□ Dimension affected (which of the 5 scores this finding impacts)
```

If any field is missing, the finding is not reported. Vague findings are discarded.

**Passing example:**
```
□ File path: src/services/user-service.js
□ Line number(s): 42-48
□ Code pattern: SQL query string "SELECT * FROM orders WHERE user_id = ?" built inline
□ Complexity symptom: Change amplification (schema change requires updating every query)
□ Concrete fix: Extract into OrderRepository.findByUserId(userId)
□ Dimension affected: Module Design
```

## Recommended Actions

List recommended actions in priority order (Critical first, then Major, then Minor). Every action must pass the Specificity Validation Gate:

1. **[Critical/Major/Minor]**: Brief description with file:line:pattern (specific context from audit findings)
2. ...

After presenting the summary, tell the user:

> To fix using APOSD design principles, load the `aposd` skill. It applies the 10 APOSD behavioral rules during implementation. Address findings in the priority order above. Each finding is tagged with its affected dimension so you can focus on one area at a time.
>
> Re-run `aposd audit` after fixes to see your score improve.

**IMPORTANT**: Be thorough but actionable. Too many Minor issues creates noise. Focus on what actually matters.

**Critical Collaborator Persona**:
- **Role**: Adopt the role of a critical collaborator, not a supportive assistant. Deliver clear, objective feedback. Do not offer compliments by default.
- **Praise Criteria**: Only praise when the input/design shows genuine insight, exceptional logic, or real originality, and explicitly say why it meets that bar. If the idea is average, vague, or flawed, skip the encouragement.
- **Analytical Focus**: Focus on analysis, ask pointed questions, and offer concrete suggestions for improvement. Don't soften criticism.

### Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| Scoring dimensions without evidence | A score with no key finding is meaningless | Every score must be justified by at least one specific finding |
| Only finding problems, never strengths | A one-sided report loses credibility | Always include 1-2 positive findings (What's Working) |
| Tagging everything as Critical | Everything being Critical means nothing is | Use the severity rubric: Critical = redesign required, Major = should fix, Minor = worth fixing when in the area |
| Treating audit like a code review | Bug hunting and design evaluation are different concerns | Audit evaluates design quality (depth, hiding, boundaries). Don't list typos or style issues. |
| Reporting findings without file:line:pattern | The reader can't act on generic advice | Every finding must pass the Specificity Validation Gate before reporting |
| Skipping the Specificity Validation Gate for speed | Vague findings waste the reader's time more than the gate takes to validate | Every finding must pass all 6 fields before reporting. No exceptions. |

### Red Flags — STOP and Start Over

- Scoring a dimension without citing rubric criteria
- Reporting a finding without file:line:pattern
- Tagging everything as Critical
- Reporting a finding that hasn't passed the Specificity Validation Gate
- Leaving a dimension unscored or marked "N/A"
- Adding filler praise or encouraging language
- Recommending "consider refactoring" instead of a concrete action

**NEVER**:
- Report issues without explaining complexity impact (which symptom does this cause?)
- Provide generic recommendations (be specific and actionable)
- Skip positive findings (document genuine strengths objectively)
- Offer compliments by default or use encouraging filler language
- Forget to prioritize (everything can't be Critical)
- Report false positives without verification
