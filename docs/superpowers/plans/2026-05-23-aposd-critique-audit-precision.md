# APOSD Critique & Audit — Precision Anchoring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate score drift and vague findings in `aposd critique` and `aposd audit` by anchoring every evaluation to cited evidence. Also separate critique (principles-only, qualitative) from audit (metrics-based, quantitative /20 scoring).

**Architecture:** Five changes applied to both SKILL.md files with tool-specific adaptations: (1) resolution anchoring in Setup, (2) specificity validation gate, (3) finding-to-concept mapping (principles for critique, dimensions for audit), (4) skill routing replacing self-fixing, (5) common mistakes rows. Plus critique-specific: remove /20 score table, strengthen Assessment A/B, change dimension→principle throughout. Plus audit-specific: count-based tactical tornado risk, score calibration note, evidence column in /20 table.

**Tech Stack:** Markdown skill files

---

### Task 1: Add Resolution Anchoring + Scope Scoping to Setup (both files)

**Files:**
- Modify: `skills/aposd-critique/SKILL.md:25-27`
- Modify: `skills/aposd-audit/SKILL.md:24-26`

- [ ] **Step 1: Edit critique Setup section**

Replace lines 25-27:

```markdown
## Setup

Before gathering assessments, resolve the target to a concrete file path or module name. The goal is a stable identifier that can be critiqued again after fixes.
```

with:

```markdown
## Setup

Before gathering assessments, resolve the target to a concrete file path or module name. The goal is a stable identifier that can be critiqued again after fixes.

**Resolution anchoring:** Before scoring, read `reference/scoring.md` for the rubric. For each dimension, identify the rubric criterion that describes the code and find specific code evidence (file:line:pattern) that demonstrates it. Every score point must cite both the rubric criterion and the code evidence.

**Scope scoping:** If the target has more than 15 files, sample systematically (first/middle/last of each directory group). Report the sample scope in the report: "Sampled 8/24 files in src/services/."
```

- [ ] **Step 2: Edit audit Setup section**

Replace lines 24-26:

```markdown
## Setup

Before starting the audit, resolve the target to a concrete file path, directory, or module name. If no target is specified, default to the current workspace root directory.
```

with:

```markdown
## Setup

Before starting the audit, resolve the target to a concrete file path, directory, or module name. If no target is specified, default to the current workspace root directory.

**Resolution anchoring:** Before scoring, read `reference/scoring.md` for the rubric. For each dimension, identify the rubric criterion that describes the code and find specific code evidence (file:line:pattern) that demonstrates it. Every score point must cite both the rubric criterion and the code evidence.

**Scope scoping:** If the target has more than 15 files, sample systematically (first/middle/last of each directory group). Report the sample scope in the report: "Sampled 8/24 files in src/services/."
```

- [ ] **Step 3: Verify edits**

Run: `head -35 skills/aposd-critique/SKILL.md | tail -10`
Expected: Shows Setup with Resolution anchoring and Scope scoping paragraphs

---

### Task 2: Add Specificity Validation Gate (both files)

**Files:**
- Modify: `skills/aposd-critique/SKILL.md` (after line 158, before Common Mistakes)
- Modify: `skills/aposd-audit/SKILL.md` (after line 135, before Recommended Actions)

- [ ] **Step 1: Add gate to critique after the "Remember" block**

Insert after line 158 (`- **Ruthless Prioritization**: ...`) and before `### Common Mistakes`:

```markdown
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
```

- [ ] **Step 2: Add gate to audit after "Positive Findings"**

Insert after line 135 (`...reduce cognitive load or change amplification.`) and before `## Recommended Actions`:

```markdown
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
```

- [ ] **Step 3: Verify**

Run: `grep -c "Specificity Validation Gate" skills/aposd-critique/SKILL.md skills/aposd-audit/SKILL.md`
Expected: Both files show count of 1

---

### Task 3: Add Evidence Column to Score Table + Finding-to-Dimension Mapping (both files)

**Files:**
- Modify: `skills/aposd-critique/SKILL.md:97-108` (score table) and `122-129` (priority issues)
- Modify: `skills/aposd-audit/SKILL.md:88-99` (score table) and `112-125` (detailed findings)

- [ ] **Step 1: Add Evidence column to critique score table (lines 97-108)**

Replace:

```markdown
#### Design Health Score

Present the 5-dimension scored table (see `reference/scoring.md` for rubric):

| # | Dimension | Score | Key Finding |
|---|-----------|-------|-------------|
| 1 | Module Design | ? | |
| 2 | Information Hiding | ? | |
| 3 | Comments & Documentation | ? | |
| 4 | Naming & Obviousness | ? | |
| 5 | Error Strategy | ? | |
| **Total** | | **??/20** | **[Rating band]**
```

with:

```markdown
#### Design Health Score

Present the 5-dimension scored table (see `reference/scoring.md` for rubric). Every score must cite both the rubric criterion and the code evidence:

| # | Dimension | Score | Key Finding | Evidence |
|---|-----------|-------|-------------|----------|
| 1 | Module Design | ? | | Rubric criterion quoted. File:line:pattern cited. |
| 2 | Information Hiding | ? | | Rubric criterion quoted. File:line:pattern cited. |
| 3 | Comments & Documentation | ? | | Rubric criterion quoted. File:line:pattern cited. |
| 4 | Naming & Obviousness | ? | | Rubric criterion quoted. File:line:pattern cited. |
| 5 | Error Strategy | ? | | Rubric criterion quoted. File:line:pattern cited. |
| **Total** | | **??/20** | **[Rating band]**
```

- [ ] **Step 2: Add dimension tag to critique Priority Issues (lines 122-129)**

Replace:

```markdown
#### Priority Issues

The 3-5 most impactful design problems, ordered by importance. For each issue:

- **[Critical/Major/Minor] What**: Name the problem clearly
- **Complexity symptom**: Change amplification? Cognitive load? Unknown unknowns?
- **Why it matters**: How this hurts future development
- **Fix**: What to do about it (be concrete)
```

with:

```markdown
#### Priority Issues

The 3-5 most impactful design problems, ordered by importance. Each issue must pass the Specificity Validation Gate before being reported. For each issue:

- **[Critical/Major/Minor] What**: Name the problem clearly
- **Dimension**: Which of the 5 scores this finding impacts (Module Design / Information Hiding / Comments & Documentation / Naming & Obviousness / Error Strategy)
- **Complexity symptom**: Change amplification? Cognitive load? Unknown unknowns?
- **Why it matters**: How this hurts future development
- **Fix**: What to do about it (be concrete)
```

- [ ] **Step 3: Add Evidence column to audit score table (lines 88-99)**

Replace:

```markdown
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
```

with:

```markdown
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
```

- [ ] **Step 4: Add dimension tag and specificity gate reference to audit Detailed Findings (lines 112-125)**

Replace:

```markdown
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
```

with:

```markdown
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
```

- [ ] **Step 5: Verify**

Run: `grep -c "Evidence" skills/aposd-critique/SKILL.md skills/aposd-audit/SKILL.md`
Expected: Each shows at least 1 match for Evidence column instruction

---

### Task 4: Tactical Tornado Risk with Count Evidence (audit only)

**Files:**
- Modify: `skills/aposd-audit/SKILL.md:101-103`

- [ ] **Step 1: Update Tactical Tornado Risk section**

Replace lines 101-103:

```markdown
### Tactical Tornado Risk

See `reference/scoring.md` for risk levels. Assess: **Low / Medium / High** based on red flag patterns found.
```

with:

```markdown
### Tactical Tornado Risk

See `reference/scoring.md` for risk levels. Assess: **Low / Medium / High** based on red flag counts found. Must cite the count:

> **Tactical Tornado Risk: HIGH** (7 red flags: 2 information leakage, 3 shallow modules, 2 pass-throughs). Rubric: "High = Pervasive shallow modules, leaky abstractions, pass-through chains."
```

- [ ] **Step 2: Verify**

Run: `grep -A5 "Tactical Tornado Risk" skills/aposd-audit/SKILL.md`
Expected: Shows the updated section with count evidence template

---

### Task 5: Strengthen Assessment A & B with Evidence/Location Requirements (critique only)

**Files:**
- Modify: `skills/aposd-critique/SKILL.md:35-63` (Assessment A) and `65-83` (Assessment B)

- [ ] **Step 1: Strengthen Assessment A principle citations**

After line 57 (`17. **Increments Are Abstractions**...`), before line 59 (`**Structural analysis**`), add:

```markdown
**Evidence requirement:** Each principle assessment must include the evidence that supports the pass/at-risk/violate judgment. Example: "Strategic Over Tactical: PASS — UserRepository (l12) extracts db logic into a module, reducing change amplification." Not just "PASS."
```

- [ ] **Step 2: Strengthen Assessment B location requirements**

After line 83 (`Return: red flags found...`), add:

```markdown
**Location requirement:** Every red flag finding must include exact file path and line numbers. Example: "Information Leakage (HIGH): SQL query string in UserService.findActive (l42) duplicates the same JOIN logic in OrderService.findByUser (l87)." Not "SQL queries are duplicated in service classes."
```

- [ ] **Step 3: Verify**

Run: `grep -c "Evidence requirement" skills/aposd-critique/SKILL.md`
Expected: 1

---

### Task 6: Replace Self-Fixing with Skill Routing (both files)

**Files:**
- Modify: `skills/aposd-critique/SKILL.md:186-190` (critique)
- Modify: `skills/aposd-audit/SKILL.md:144-148` (audit)

- [ ] **Step 1: Replace critique self-fixing instructions**

Replace lines 186-190:

```markdown
After presenting the summary, tell the user:

> You can ask me to address these one at a time, all at once, or in any order you prefer.
>
> Re-run `aposd critique` after fixes to see your score improve.
```

with:

```markdown
After presenting the summary, tell the user:

> To fix using APOSD design principles, load the `aposd` skill. It applies the 10 APOSD behavioral rules during implementation. Address findings in the priority order above. Each finding is tagged with its affected dimension so you can focus on one area at a time.
>
> Re-run `aposd critique` after fixes to see your score improve.
```

- [ ] **Step 2: Replace audit self-fixing instructions**

Replace lines 144-148:

```markdown
After presenting the summary, tell the user:

> You can ask me to address these one at a time, all at once, or in any order you prefer.
>
> Re-run `aposd audit` after fixes to see your score improve.
```

with:

```markdown
After presenting the summary, tell the user:

> To fix using APOSD design principles, load the `aposd` skill. It applies the 10 APOSD behavioral rules during implementation. Address findings in the priority order above. Each finding is tagged with its affected dimension so you can focus on one area at a time.
>
> Re-run `aposd audit` after fixes to see your score improve.
```

- [ ] **Step 3: Also update critique Recommended Actions format**

Replace lines 177-184:

```markdown
### Recommended Actions

After receiving the user's answers, present a prioritized action summary:

1. **[Critical/Major/Minor]**: Brief description of what to fix (specific context from critique findings)
2. ...

Order by the user's stated priorities first, then by impact. Include enough context that each item is actionable.
```

with:

```markdown
### Recommended Actions

After receiving the user's answers, present a prioritized action summary. Every action must pass the Specificity Validation Gate:

1. **[Critical/Major/Minor]**: Brief description with file:line:pattern (specific context from critique findings)
2. ...

Order by the user's stated priorities first, then by impact. Include enough context that each item is actionable.
```

- [ ] **Step 4: Update audit Recommended Actions format similarly**

Replace lines 137-143:

```markdown
## Recommended Actions

List recommended actions in priority order (Critical first, then Major, then Minor):

1. **[Critical/Major/Minor]**: Brief description (specific context from audit findings)
2. ...
```

with:

```markdown
## Recommended Actions

List recommended actions in priority order (Critical first, then Major, then Minor). Every action must pass the Specificity Validation Gate:

1. **[Critical/Major/Minor]**: Brief description with file:line:pattern (specific context from audit findings)
2. ...
```

- [ ] **Step 5: Verify**

Run: `grep -c "load the \`aposd\` skill" skills/aposd-critique/SKILL.md skills/aposd-audit/SKILL.md`
Expected: Both show count of 1

---

### Task 7: Update Common Mistakes Tables (both files)

**Files:**
- Modify: `skills/aposd-critique/SKILL.md:160-167` (critique)
- Modify: `skills/aposd-audit/SKILL.md:157-164` (audit)

- [ ] **Step 1: Add row to critique Common Mistakes**

Affter line 167, add to the table:

```markdown
| Reporting findings without file:line:pattern | The reader can't act on generic advice | Every finding must pass the Specificity Validation Gate before reporting |
```

Insert before the empty line following the table (before `### Ask the User`). The full table will become:

```markdown
| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| Running assessments sequentially in one head | Both assessments silently anchor to each other; the second output is biased by the first | Use sub-agents or separate contexts. If you can't, note the bias in the report. |
| Only listing red flags without explaining complexity impact | The reader doesn't know WHY each finding matters | Tag each finding with the complexity symptom it causes (change amplification / cognitive load / unknown unknowns). |
| Writing generic persona descriptions | "Tactical Tornado would write shallow code" adds nothing | Name the specific function, line, and pattern. "Tactical Tornado would merge UserService with OrderService — they share a db connection." |
| Scoring without evidence | A score of 2 with no key finding is useless | Every score must have a specific key finding that justifies it. |
| Reporting findings without file:line:pattern | The reader can't act on generic advice | Every finding must pass the Specificity Validation Gate before reporting |
```

- [ ] **Step 2: Add row to audit Common Mistakes**

Affter line 164, add to the table:

```markdown
| Reporting findings without file:line:pattern | The reader can't act on generic advice | Every finding must pass the Specificity Validation Gate before reporting |
```

Insert before the `**NEVER**` section. The full table will become:

```markdown
| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| Scoring dimensions without evidence | A score with no key finding is meaningless | Every score must be justified by at least one specific finding |
| Only finding problems, never strengths | A one-sided report loses credibility | Always include 1-2 positive findings (What's Working) |
| Tagging everything as Critical | Everything being Critical means nothing is | Use the severity rubric: Critical = redesign required, Major = should fix, Minor = worth fixing when in the area |
| Treating audit like a code review | Bug hunting and design evaluation are different concerns | Audit evaluates design quality (depth, hiding, boundaries). Don't list typos or style issues. |
| Reporting findings without file:line:pattern | The reader can't act on generic advice | Every finding must pass the Specificity Validation Gate before reporting |
```

- [ ] **Step 3: Verify**

Run: `grep -c "Specificity Validation Gate" skills/aposd-critique/SKILL.md skills/aposd-audit/SKILL.md`
Expected: Critique shows 3+ matches, audit shows 3+ matches (gate section + common mistakes + recommended actions)
