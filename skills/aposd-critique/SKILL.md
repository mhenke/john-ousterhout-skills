---
name: aposd-critique
description: Use when evaluating whether code follows APOSD design principles. Also use when you suspect code was written tactically and want to assess whether the approach was strategic or tactical.
license: MIT
---

# aposd critique — Design Critique

Principles-based design evaluation from *A Philosophy of Software Design, 2nd Edition* (Ousterhout, 2021). Combines two independent assessments into a single report with persona red flags.

**Usage:** `aposd critique [module, class, or subsystem]`

**Example output for a shallow `UserService` class:**
```
Tactical Tornado Verdict: CONFIRMED. 4 red flags.
- Information Leakage: table/column names in every method
- Shallow Module: 6 one-liner methods
- Pass-Through: all methods just delegate to self.db
- Repetition: self.db.query(...) appears 5 times

Principles Assessment: 12/18 pass, 4 at risk, 2 violate
Strategic Thinker: Consolidate into UserRepository.find(**filters)
```

## Setup

Before gathering assessments, resolve the target to a concrete file path or module name. The goal is a stable identifier that can be critiqued again after fixes.

**Resolution anchoring:** Before assessing each principle, find specific code evidence (file:line:pattern) that supports the pass/at-risk/violate judgment. Every principle assessment must cite the code evidence.

**Scope scoping:** If the target has more than 15 files, sample systematically (first/middle/last of each directory group). Report the sample scope in the report: "Sampled 8/24 files in src/services/."

## Gather Assessments

Launch two independent assessments. **Neither may see the other's output.** This isolation is what makes the combined critique honest. Running both in one head silently anchors them to each other.

Fall back to sequential in-head work only if the environment cannot spawn sub-agents.

#### Assessment A: Strategic Thinker Review

Evaluate the code as the Strategic Thinker persona would. Focus on:

**Design Principles Assessment** (passes / at risk / violates) — consult `reference/principles.md` for full depth on each:

1. **Strategic Over Tactical**: Does the code show design investment or was it written to "just work"?
2. **Deep Modules**: Is the interface significantly simpler than the implementation?
3. **Information Hiding**: Do interfaces reveal what they do without revealing how? Any leakage?
4. **General-Purpose Design**: Are modules designed for one use case or could they serve multiple?
5. **Different Layer, Different Abstraction**: Does each layer provide a distinct abstraction?
6. **Pull Complexity Downward**: Is the common case trivial for callers?
7. **Better Together or Better Apart**: Are module boundaries in the right place?
8. **Define Errors Out of Existence**: Could common errors be eliminated by redesigning the interface?
9. **Design It Twice**: Was more than one design considered? Does the chosen design show evidence of alternative evaluation?
10. **Comments Describe Non-Obvious**: Do comments add information beyond what's in the code?
11. **Comments First**: Do interface comments read like they were designed, not patched in?
12. **Choosing Names**: Do names create an image — precise, consistent, no extra words?
13. **Code Should Be Obvious**: Can someone understand this without deep thought?
14. **Modifying Existing Code**: Does the code show evidence of strategic modification?
15. **Consistency**: Are naming, patterns, and conventions consistent?
16. **Design for the Future**: Is volatility encapsulated without over-engineering?
17. **Performance as Design**: Are design-level decisions sound, not micro-optimized?
18. **Increments Are Abstractions**: Was work decomposed by abstraction boundary, not feature?

**Evidence requirement:** Each principle assessment must include the evidence that supports the pass/at-risk/violate judgment. Example: "Strategic Over Tactical: PASS — UserRepository (l12) extracts db logic into a module, reducing change amplification." Not just "PASS."

**Structural analysis**: module depth, abstraction layers, interface quality, error strategy.

**Improvement ranking**: Top 3 changes that would most reduce complexity, ranked by impact.

Return structured findings: per-principle assessment, what's working (2-3 items), priority issues (3-5 with what/why/fix), and the single most impactful design change.

#### Assessment B: Tactical Tornado Detection

Evaluate the code as the Tactical Tornado persona would produce it. Look for:

**Red Flag Scan** (in priority order):
1. Information Leakage — same knowledge in multiple places
2. Shallow Module — interface as complex as implementation
3. Temporal Decomposition — code mirrors execution order
4. Pass-Through Method — methods that add no value
5. Pass-Through Variables — context threaded unused
6. Repetition — duplicated nontrivial code
7. Special-General Mixture — general code with special-case logic
8. Conjoined Methods (entanglement) — can't understand one without the other
9. Overexposure — API forces learning rare features
10-15. Comment, naming, and obviousness red flags

**Tactical tornado signature**: Count the number of red flags found and assess whether the codebase shows systematic tactical patterns.

Return: red flags found (ordered by severity), tactical tornado risk (low/medium/high), specific examples of each pattern found.

**Location requirement:** Every red flag finding must include exact file path and line numbers. Example: "Information Leakage (HIGH): SQL query string in UserService.findActive (l42) duplicates the same JOIN logic in OrderService.findByUser (l87)." Not "SQL queries are duplicated in service classes."

### Raw Assessment Output

Before combining, present the raw findings from each assessment separately so the reader can see each perspective clearly.

**Assessment A output:** [Strategic Thinker findings]

**Assessment B output:** [Tactical Tornado findings]

### Generate Combined Critique Report

Synthesize both assessments into a single report. Weave the findings together, noting where both assessments agree, where the Strategic Thinker found strengths the Tactical Tornado scan missed, and where the Tactical Tornado scan caught issues the Strategic Thinker overlooked.
#### Tactical Tornado Verdict

Start here. Does this code look like it was written tactically? Summarize the Tactical Tornado detection findings, with counts and file locations. Note any additional patterns the detection found that the Strategic Thinker missed.

#### Overall Impression

A brief gut reaction: what works, what doesn't, and the single biggest opportunity for reducing complexity.

#### What's Working

Highlight 2-3 things done well. Be specific about why they reduce complexity.

#### Priority Issues

The 3-5 most impactful design problems, ordered by importance. Each issue must pass the Specificity Validation Gate before being reported. For each issue:

- **[Critical/Major/Minor] What**: Name the problem clearly
- **Principle**: Which of the 18 principles this finding relates to (e.g., Deep Modules, Information Hiding, Define Errors Out of Existence)
- **Complexity symptom**: Change amplification? Cognitive load? Unknown unknowns?
- **Why it matters**: How this hurts future development
- **Fix**: What to do about it (be concrete)

#### Persona Walkthrough

Consult `reference/personas.md`. Walk through each persona explicitly:

**Tactical Tornado walkthrough:** "If the Tactical Tornado wrote this code, they would let the wrapper grow its own policy language and edge-case heuristics, which increases drift risk. The code would accumulate special-case logic over time as features are tacked on." List the specific red flags found — name the exact function, line, and pattern. Do not write generic descriptions; write specific findings.

**Strategic Thinker walkthrough:** "If the Strategic Thinker were to redesign this, they would keep the wrapper thin, with one clean reference back to the core abstraction and minimal local interpretation. No policy language, no heuristic accretion." Be specific about what they would do differently.

#### Minor Observations

Quick notes on smaller issues worth addressing.

#### Questions to Consider

Provocative questions that might unlock better designs:
- "What if this module's interface were designed for the caller, not the implementation?"
- "Could this error case be eliminated by changing the interface contract?"
- "Would merging these two classes produce a deeper module?"

**Remember**:
- **Critical Collaborator**: Adopt the role of a critical collaborator, not a supportive assistant. Deliver clear, objective feedback. Do not offer compliments by default.
- **Praise Criteria**: Only praise when the input/design shows genuine insight, exceptional logic, or real originality, and explicitly say why it meets that bar. If the idea is average, vague, or flawed, skip the encouragement.
- **Analytical Focus**: Focus on analysis, ask pointed questions, and offer concrete suggestions for improvement.
- **Directness**: Be direct. Vague feedback wastes everyone's time. Don't soften criticism. Developers need honest feedback to ship better design.
- **Specificity**: Be specific. "The findById method," not "some functions."
- **Complexity Impact**: Say what's wrong AND why it increases complexity (change amplification, cognitive load, unknown unknowns).
- **Concrete Suggestions**: Give concrete suggestions. Cut "consider exploring..." entirely.
- **Ruthless Prioritization**: Prioritize ruthlessly. If everything is important, nothing is.

### Specificity Validation Gate

Before reporting any finding, self-validate against this checklist:

```
□ File path (absolute or relative to target)
□ Line number(s)
□ Code pattern (exact snippet, 1-3 lines)
□ Complexity symptom (change amplification / cognitive load / unknown unknowns)
□ Concrete fix (an action — "extract into UserRepository.find()" not "consider refactoring")
□ Principle affected (which of the 18 design principles this finding relates to)
```

If any field is missing, the finding is not reported. Vague findings are discarded.

### Common Mistakes

| Mistake | Why It's Wrong | Fix |
|---------|---------------|-----|
| Running assessments sequentially in one head | Both assessments silently anchor to each other; the second output is biased by the first | Use sub-agents or separate contexts. If you can't, note the bias in the report. |
| Only listing red flags without explaining complexity impact | The reader doesn't know WHY each finding matters | Tag each finding with the complexity symptom it causes (change amplification / cognitive load / unknown unknowns). |
| Writing generic persona descriptions | "Tactical Tornado would write shallow code" adds nothing | Name the specific function, line, and pattern. "Tactical Tornado would merge UserService with OrderService — they share a db connection." |
| Assessing principles without evidence | PASS/FAIL with no code evidence is useless | Every principle assessment must cite the code evidence that supports the judgment. |
| Reporting findings without file:line:pattern | The reader can't act on generic advice | Every finding must pass the Specificity Validation Gate before reporting |
| Skipping the Specificity Validation Gate for speed | Vague findings waste the reader's time more than the gate takes to validate | Every finding must pass all 6 fields before reporting. No exceptions. |

### Red Flags — STOP and Start Over

- Reporting a finding without file:line:pattern
- Assessing a principle without citing code evidence
- Combining both assessments into a single report without isolation
- Describing a persona generically instead of citing specific code
- Tagging a finding without a complexity symptom
- Reporting more than 5 priority issues
- Using vague language like "consider refactoring" instead of concrete actions

### Ask the User

After presenting findings, ask 1-2 targeted questions based on what was actually found:

1. **Priority direction**: Based on the issues found, ask which principle area matters most. For example: "I found problems with module depth, information hiding, and error strategy. Which area should we tackle first?"

2. **Scope**: Ask how much the user wants to take on. For example: "I found N issues. Want to address everything, or focus on the top 3?"

### Recommended Actions

After receiving the user's answers, present a prioritized action summary. Every action must pass the Specificity Validation Gate:

1. **[Critical/Major/Minor]**: Brief description with file:line:pattern (specific context from critique findings)
2. ...

Order by the user's stated priorities first, then by impact. Include enough context that each item is actionable.

After presenting the summary, tell the user:

> To fix using APOSD design principles, load the `aposd` skill. It applies the 10 APOSD behavioral rules during implementation. Address findings in the priority order above. Each finding is tagged with its affected principle so you can focus on one area at a time.
>
> Re-run `aposd critique` after fixes to see your score improve.
