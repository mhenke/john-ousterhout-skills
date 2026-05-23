---
name: aposd-audit
description: Use when you need a systematic scored evaluation of design quality across multiple dimensions. Also use before major refactoring to identify which areas need the most attention, or when code shows red flags like shallow modules, information leakage, and pass-through methods.
license: MIT
---

# aposd audit — Design Quality Audit

Run systematic design quality checks and generate a comprehensive report. Don't fix issues; document them for review.

This is a code-level design audit — check what's measurable and verifiable in the implementation. Every dimension is scored by counting concrete, observable constructs. Fix the count → score goes up, every time.

**Follows the impeccable audit convention:** measure what's objectively countable, not what's interpretive.

**Scoring rubric:** Score each dimension 0-4. Total /20. Rating bands: 18-20 Excellent, 14-17 Good, 10-13 Acceptable, 6-9 Poor, 0-5 Critical.

## Setup

Resolve the target to a concrete file path, directory, or module name. If no target is specified, default to the current workspace root directory.

**Scope scoping:** If the target has more than 15 files, sample systematically (first/middle/last of each directory group). Report the sample scope: "Sampled 8/24 files in src/services/."

## Diagnostic Scan

Run comprehensive checks across 5 dimensions. Score each dimension 0-4 by counting concrete, observable constructs.

### 1. Pass-Through Proliferation

**Count:** Pass-through methods (method body only delegates to another method with the same signature) + pass-through variable chains (context/config threaded through methods that don't use it).

**Score 0-4:**
- 4: 0 pass-through constructs found
- 3: 1-2 isolated pass-through methods
- 2: 3-5 pass-through methods OR 1 pass-through variable chain
- 1: 6-10 pass-through methods OR 2+ variable chains
- 0: 10+ pass-through methods OR any pass-through chain (A→B→C)

**Calibration:**
- ✓ Counts: `getUser()` body is exactly `return this.db.fetchUser(id)`
- ✓ Counts: `handleClick(e)` body is `this.onClick(e)` with nothing else
- ✓ Counts: `processData()` → `transformData()` → `applyRules()` where middle just calls the next
- ✓ Counts: `config` threaded through 5 methods that only pass it to a 6th that uses it
- ✗ Doesn't count: method adds validation, logging, or error handling around the delegate
- ✗ Doesn't count: method transforms args (e.g., `return this.db.query(normalize(id))`)
- ✗ Doesn't count: method combines multiple delegates (e.g., `a(x); return b(y)`)

### 2. Information Duplication

**Count:** Instances where the same design knowledge (URL paths, schema fields, business rules, configuration keys, magic strings/numbers) appears in multiple independent modules. Count each distinct piece of knowledge that's duplicated.

**Score 0-4:**
- 4: 0 instances of duplicated knowledge
- 3: 1-2 isolated instances
- 2: 3-4 instances
- 1: 5-7 instances
- 0: 8+ instances or a systemic pattern (same rule in 5+ files)

**Calibration:**
- ✓ Counts: `"SELECT * FROM orders WHERE status = 'active'"` in user-service.js and order-service.js
- ✓ Counts: `MAX_RETRIES = 3` defined in retry.js and again in network-client.js
- ✓ Counts: `"orders_expire_after_days": 30` in both config schema and validation logic
- ✗ Doesn't count: common import (`import React from "react"`) — that's a dependency, not leakage
- ✗ Doesn't count: function `formatDate()` called from multiple modules — that's normal usage
- ✗ Doesn't count: same error message string used in a try/catch and a test assertion
- ✗ Deduplicate: only count each distinct piece of knowledge once, even if spread across 5+ files

### 3. Interface Documentation

**Count:** Number of public methods/functions without interface comments. Report as both count and percentage of total public methods.

**Score 0-4:**
- 4: ≥90% of public methods documented
- 3: 70-89% documented
- 2: 40-69% documented
- 1: 10-39% documented
- 0: <10% documented

**Calibration:**
- ✓ Counts as documented: has a JSDoc/comment block describing what the method does, its parameters, or its return value
- ✓ Counts as undocumented: public method with only a `// TODO` or inline comment, or no comment at all
- ✗ Doesn't count: private/internal methods — only public/protected interface
- ✗ Doesn't count: getters/setters that only read/write a field — skip these from the total
- ✗ Doesn't count: comments that only repeat the method name (`/** Get user */ getUser()`)

### 4. Naming Quality

**Count:** Identifiers matching the vague names blocklist — `data`, `info`, `tmp`, `handle`, `process`, `util`, `helper`, `manager`, `stuff`, `thing`. Also count violations of project naming conventions (inconsistent casing, mixed patterns).

**Score 0-4:**
- 4: 0 vague names, consistent conventions
- 3: 1-2 vague names, minor inconsistency
- 2: 3-5 vague names or inconsistent conventions
- 1: 6-10 vague names or project-wide naming inconsistency
- 0: 10+ vague names or no discernible naming convention

**Calibration:**
- ✓ Counts: `data`, `info`, `tmp`, `handle`, `process`, `util`, `helper`, `manager`, `stuff`, `thing` used as function names, class names, or variable names
- ✓ Counts: `camelCase` and `snake_case` mixed in the same module
- ✓ Counts: `UserService` and `user_service` referring to the same concept
- ✗ Doesn't count: `data` as a parameter in a generic utility (e.g., `JSON.parse(data)`) — context matters
- ✗ Doesn't count: `tmp` in a 3-line test helper scoped to a single function

### 5. Exception Discipline

**Count:** Custom exception/error classes defined (not standard library types). Count catch blocks that only re-throw, log, or swallow the same exception type.

**Score 0-4:**
- 4: 0 custom exception types, clean handling
- 3: 1-2 custom exceptions, no catch-and-rethrow patterns
- 2: 3-5 custom exceptions or 1-2 catch-and-rethrow
- 1: 6-10 custom exceptions or 3-5 catch-and-rethrow
- 0: 10+ custom exceptions or 5+ catch-and-rethrow

**Calibration:**
- ✓ Counts: `class UserNotFoundError extends Error {}` — custom exception class
- ✓ Counts: `class PaymentError extends Error { constructor(code, msg) { super(msg); this.code = code; } }` — custom with extra fields
- ✓ Counts: `try { ... } catch (e) { throw new ApiError(e.message); }` — catch-and-rethrow
- ✓ Counts: `try { ... } catch (e) { log(e); throw e; }` — log-and-rethrow
- ✗ Doesn't count: using built-in `Error`, `TypeError`, `RangeError` directly — only count custom subclasses
- ✗ Doesn't count: `try { ... } catch (e) { return defaultValue; }` — that's masking, not rethrowing
- ✗ Doesn't count: catch block at module boundary that transforms for the caller (`catch (e) { throw new ApiError(500, e.message); }`) — that's proper masking

## Generate Report

### Design Health Score

Score each dimension 0-4. Every score must cite both the rubric criterion and the code evidence:

| # | Dimension | Score | Key Finding | Evidence |
|---|-----------|-------|-------------|----------|
| 1 | Pass-Through Proliferation | ? | Count found | File:line:pattern cited |
| 2 | Information Duplication | ? | Count found | File:line:pattern cited |
| 3 | Interface Documentation | ? | % documented | File:line:pattern cited |
| 4 | Naming Quality | ? | Count found | File:line:pattern cited |
| 5 | Exception Discipline | ? | Count found | File:line:pattern cited |
| **Total** | | **??/20** | **[Rating band]** |

### Tactical Tornado Risk

Assess based on red flag counts found across the 5 dimensions:

- **Low**: 0-1 dimensions scored ≤2, no systemic patterns
- **Medium**: 2-3 dimensions scored ≤2, or 1-2 systemic patterns
- **High**: 4+ dimensions scored ≤2, or pervasive pass-throughs/leakage

### Executive Summary
- Design Health Score: **??/20** ([rating band])
- Tactical Tornado Risk: **[Low / Medium / High]**
- Total issues found (count by severity: P0/P1/P2/P3)
- Top 3-5 critical issues
- Recommended next steps

### Detailed Findings by Severity

Every finding must pass the Specificity Validation Gate. Tag with P0-P3 severity:

- **P0 Blocking**: Prevents task completion. Fix immediately
- **P1 Major**: Significant complexity increase. Fix before next milestone
- **P2 Minor**: Notable but local. Fix when in the area
- **P3 Polish**: Worth fixing, no urgency

For each issue, document:
- **[P0/P1/P2/P3] Issue name**
- **Location**: Component, file, line
- **Dimension**: Pass-Through / Duplication / Documentation / Naming / Exceptions
- **Count**: How many instances found
- **Impact**: How it affects future development
- **Recommendation**: Concrete action (not "consider refactoring")

### Patterns & Systemic Issues

Identify recurring problems that indicate systemic gaps rather than one-off mistakes:
- "Pass-through methods appear in every service layer class — 14 total across 6 files"
- "The business rule 'orders expire after 30 days' is embedded in 5 different modules"

### Positive Findings

Note what's working well: dimensions scoring ≥3, clean patterns that prevent complexity. Be objective — explain precisely why they reduce change amplification or cognitive load.

### Specificity Validation Gate

Before reporting any finding, self-validate:

```
□ File path (absolute or relative to target)
□ Line number(s)
□ Code pattern (exact snippet, 1-3 lines)
□ Dimension (Pass-Through / Duplication / Documentation / Naming / Exceptions)
□ Count (how many instances)
□ Recommendation (concrete action)
```

Missing any field → finding is discarded.

**Passing example:**
```
□ File path: src/services/user-service.js
□ Line number(s): 42-48
□ Code pattern: "SELECT * FROM orders WHERE user_id = ?" built inline, same query in order-service.js:87
□ Dimension: Information Duplication
□ Count: 2 instances of the same SQL pattern
□ Recommendation: Extract into OrderRepository.findByUserId(userId)
```

## Recommended Actions

List recommended actions in priority order (P0 first, then P1, then P2):

1. **[P0/P1/P2/P3]**: Brief description with file:line:pattern (specific context from audit findings)
2. ...

After presenting the summary, tell the user:

> To fix using APOSD design principles, load the `aposd` skill. It applies the 10 APOSD behavioral rules during implementation. Address findings in the priority order above. Each finding is tagged with its affected dimension so you can focus on one area at a time.
>
> Re-run `aposd audit` after fixes to see your score improve.

**IMPORTANT**: Be thorough but actionable. Too many P3 issues creates noise. Focus on what actually matters.

### Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| Scoring dimensions without evidence | A score with no count is meaningless | Every score must cite the count and file:line:pattern |
| Judging design quality instead of counting | "This module is shallow" — interpretive, not measurable | Count pass-throughs. Count duplications. Count missing docs. |
| Tagging everything as P0 | Everything being P0 means nothing is | P0 = blocks progress, P1 = major fix, P2 = local, P3 = polish |
| Treating audit like a code review | Bug hunting and design evaluation are different | Audit measures design metrics. Don't list typos or style issues. |
| Reporting findings without file:line:pattern | Reader can't act on generic advice | Every finding must pass the Specificity Validation Gate |

### Red Flags — STOP and Start Over

- Scoring a dimension without citing a count
- Reporting a finding without file:line:pattern
- Tagging everything as P0
- Reporting a finding that hasn't passed the Specificity Validation Gate
- Leaving a dimension unscored or marked "N/A"
- Recommending "consider refactoring" instead of a concrete action
- Judging design quality instead of counting measurable constructs

**NEVER**:
- Report issues without a count (how many instances?)
- Provide generic recommendations (be specific and actionable)
- Skip positive findings (document objective strengths)
- Forget to prioritize (everything can't be P0)
- Report false positives without verification
