> **Canonical copy.** Edit here first. Vendored copies in `skills/*/references/` are snapshots.

# Personas — Tactical Tornado & Strategic Thinker

Two design personas for evaluating code through the APOSD lens. Use in critique and audit to surface different failure modes and design ideals.

---

## 1. Tactical Tornado

**Alias:** The Fast Shippper

**Motto:** "Working code is enough."

**Profile:** Produces massive output quickly. Every feature gets a patch, every bug gets a quick fix. Code works today but is increasingly difficult to change tomorrow. Doesn't see design as part of the job.

**Behaviors:**
- Writes code in execution order (temporal decomposition)
- Creates shallow classes with thin wrappers around primitives
- Solves today's problem in the most direct way, ignoring tomorrow
- Swallows exceptions or propagates every error type
- Comments are afterthoughts or nonexistent
- Names are vague (`data`, `info`, `process`, `handle`)
- Leaves dead code, unused imports, and stale comments
- Changes 10 files when 2 would do (drive-by refactoring)

**Detection patterns:**
- Pass-through chains: `A → B → C → D` where each adds nothing
- Information leakage: same URL, config, or business rule in 4 places
- God classes: one module knows about everything
- Shallow modules: interface as complex as implementation
- Comment-free code: no interface documentation
- Error handling that mirrors the happy path

**Red Flags in code:**
```python
# Tactical Tornado output
def process_data(data, config, logger, cache):
    # process the data
    result = do_something(data, config)
    logger.info("done")
    cache.set("key", result)
    return result
# Note: 4 parameters, 3 passed through unused,
# vague name, no interface comment
```

---

## 2. Strategic Thinker

**Alias:** The Architect

**Motto:** "Working code isn't enough."

**Profile:** Invests in design with every task. Creates modules that hide complexity behind simple interfaces. Code is obvious, commented, and easy to change. Thinks in abstractions, not execution steps.

**Behaviors:**
- Designs the interface before writing the implementation
- Creates deep modules: simple interface, powerful implementation
- Pulls complexity downward so callers have trivial common cases
- Defines errors out of existence where possible
- Writes interface comments first (what, not how)
- Names create an image — precise, consistent, no extra words
- Leaves every module cleaner than they found it
- Runs the obviousness check before marking done

**Detection patterns:**
- One method replaces five: `find(**filters)` instead of `findById`, `findByEmail`, etc.
- Interface comments describe contract, not mechanism
- Common case is a single call with no setup
- Error types are few and meaningful
- Changing a requirement changes one module, not six
- Code is obvious at first read

**Code signature:**
```python
# Strategic Thinker output
class UserRepository:
    """Access users by criteria. Hides storage details."""
    
    def find(self, **filters):
        """Find users matching criteria.
        
        Returns User if filtering by unique field (id, email),
        otherwise returns list. Raises UserNotFound if no match
        for unique field lookup.
        """
```

---

## Using Personas in Critique

When critiquing code, evaluate from both perspectives:

1. **Tactical Tornado walkthrough:** "If this code was written by the Tactical Tornado, what patterns would I see?" Check for pass-throughs, leakage, shallow modules, missing comments, vague names.

2. **Strategic Thinker walkthrough:** "If the Strategic Thinker were to redesign this, what would they change?" Identify the single most impactful improvement: make a module deeper, eliminate an error case, consolidate leaked information.

Report specific findings as persona red flags:

> **Tactical Tornado red flags detected:**
> - 3 pass-through methods in the service layer
> - Configuration format knowledge leaked across 4 modules
> - No interface comments on any public method
>
> **Strategic Thinker recommendation:**
> - Merge `findById`, `findByEmail`, `findByName` into a single `find(**filters)` method
> - The interface is shallow — the class has 8 public methods, each a one-liner

---

## When to Use Which

| Context | Primary Persona | Secondary Persona |
|---------|----------------|-------------------|
| Reviewing new code | Strategic Thinker | Tactical Tornado |
| Debugging existing issues | Tactical Tornado | Strategic Thinker |
| Refactoring legacy code | Tactical Tornado | Strategic Thinker |
| Pre-implementation design | Strategic Thinker | — |
| Postmortem / root cause | Tactical Tornado | Strategic Thinker |
