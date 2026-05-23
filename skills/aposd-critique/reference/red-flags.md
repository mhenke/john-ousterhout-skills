# Red Flags — Deep Reference

From *A Philosophy of Software Design, 2nd Edition* (Ousterhout, 2021). Listed in priority order. Each red flag includes symptom, why it increases complexity, detection pattern, and fix strategy.

---

## 1. Information Leakage

**Priority:** Most important red flag in the book.

**Symptom:** The same design knowledge (a decision, fact, or assumption) is reflected in multiple modules.

**Why it increases complexity:** Creates **change amplification** — when that design knowledge changes, every affected module must be updated. Creates **unknown unknowns** — you may not know which modules share the leaked information.

**Detection pattern:** Ask "if this requirement changes, how many modules would need to change?" If more than one, there may be leakage. Also: two modules that both reference the same external concept (file format, protocol, business rule).

**Fix strategy:**
- Consolidate: pull the leaked information into a single module
- Re-encapsulate: hide the information so it only affects one module
- If modules are small and closely tied, merge them

**Example:** Two classes that both know about HTTP header structure. Consolidate into a single `HttpHeaders` class.

---

## 2. Shallow Module

**Symptom:** The interface for a class or method isn't much simpler than its implementation.

**Why it increases complexity:** Increases **cognitive load** — callers must learn an interface that's as complex as the implementation they'd write themselves. The module provides no abstraction benefit.

**Detection pattern:** A method whose body is almost as long as its signature. A class with many small methods, each a thin wrapper. "Does this class do more work than it takes to describe its interface?"

**Fix strategy:**
- Merge the shallow module into its caller or a deeper module
- Redesign to increase the benefit-to-cost ratio — provide more functionality through the same interface
- Eliminate methods that exist only to pass through to another layer

**Example:** A `UserRepository` with `findById`, `findByEmail`, `findByName`, `countActive`, `countByRole` — each a one-liner SQL wrapper. Replace with a single `find(**filters)` method.

---

## 3. Temporal Decomposition

**Symptom:** The code structure is based on the order in which operations are executed, not on information hiding.

**Why it increases complexity:** Creates **unknown unknowns** — the design doesn't reflect the system's abstractions, so developers must understand the full execution sequence to make changes. Methods tend to be conjoined (you can't understand one without knowing the execution order).

**Detection pattern:** Class names that reflect execution stages: `ReadInput`, `ProcessData`, `WriteOutput`. Methods in caller that must be called in a specific sequence.

**Fix strategy:** Redesign around abstractions, not execution steps. Each module should hide a design decision, not implement a phase of processing.

**Example:** Instead of `FetchData → ParseData → AnalyzeData → FormatOutput → DisplayResults`, design around abstractions: `DataFetcher`, `Analyzer`, `Display`.

---

## 4. Pass-Through Method

**Symptom:** A method does almost nothing except pass its arguments to another method with a similar signature.

**Why it increases complexity:** Increases **cognitive load** — adds a method that provides no abstraction benefit. The developer must read through empty methods to find the real implementation. Shallow by definition.

**Detection pattern:** Method A calls Method B with all the same parameters. Method B calls Method C with the same parameters. No value added at each step.

**Fix strategy:** Eliminate the pass-through. Call the deeper method directly. If the pass-through is required by an interface, consider whether the interface itself should be restructured.

---

## 5. Pass-Through Variables

**Symptom:** A variable (configuration, context, or shared data) is threaded through multiple layers of method calls, where most layers don't use it — they only pass it to deeper layers.

**Why it increases complexity:** Increases **cognitive load** — every intermediate method signature includes the variable even though it doesn't use it. Creates **change amplification** — adding a new piece of shared data requires changing every intermediate method signature.

**Detection pattern:** A parameter that appears in method after method, unchanged. Often named `config`, `context`, `options`, or similar.

**Fix strategy:**
- Use a global variable (Ousterhout's suggestion for truly cross-cutting concerns)
- Store the shared context in an object that's already shared between the layers
- Use a dependency injection container

**Example:** A `requestContext` passed through `handler → controller → service → repository` where only `repository` uses it. Store it in a thread-local or request-scoped container instead.

---

## 6. Repetition

**Symptom:** The same nontrivial piece of code appears in multiple places.

**Why it increases complexity:** Creates **change amplification** — fixing a bug or changing behavior requires finding and updating every copy. Creates **unknown unknowns** — you may miss one.

**Detection pattern:** Search for duplicated blocks. Ctrl+C/V patterns. Copy-paste with minor modifications.

**Fix strategy:** Extract into a shared method or module. If the copies have slight variations, consider whether a general-purpose interface can serve all use cases.

---

## 7. Special-General Mixture

**Symptom:** Special-purpose code for a particular use case is mixed into a general-purpose mechanism.

**Why it increases complexity:** Creates **change amplification** — special-purpose changes may require modifying the general-purpose mechanism. Creates **information leakage** between the mechanism and the use case.

**Detection pattern:** A "utility" class that contains both generic utility methods and methods specific to one caller. A configuration module that has defaults specific to one deployment.

**Fix strategy:** Separate general-purpose and special-purpose code. The general-purpose module should not know about its use cases.

---

## 8. Conjoined Methods (a.k.a. Entanglement)

**Symptom:** Two methods have so many dependencies that you can't understand one without understanding the other.

**Why it increases complexity:** Increases **cognitive load** — you must hold both methods in your head simultaneously. Each change in one method may require a corresponding change in the other.

**Detection pattern:** You find yourself flipping back and forth between two methods to understand how they work together. A method that is always called immediately before or after another specific method.

**Fix strategy:** Merge them into a single method. If they represent different abstractions, clarify the boundary so each can be understood independently.

---

## 9. Overexposure

**Symptom:** An API forces callers to be aware of rarely-used features in order to use commonly-used features.

**Why it increases complexity:** Increases **cognitive load** — every caller must navigate the full complexity of the API even for simple operations.

**Detection pattern:** A class with many public methods where most callers only use one or two. A constructor with many parameters where most callers only set one or two.

**Fix strategy:** Split the API into a core (common operations) and extensions (rare operations). Provide defaults for rarely-used parameters. Consider creating separate classes for different use cases.

---

## 10. Comment Repeats Code

**Symptom:** All of the information in a comment is immediately obvious from reading the code next to the comment.

**Why it increases complexity:** Does not reduce complexity — wastes reader's time. Creates maintenance burden without benefit.

**Detection pattern:**
```python
# Increment the counter by 1
counter += 1
```

**Fix strategy:** Remove the comment, or replace it with a higher-level comment that explains *why* the code exists, not *what* it does.

---

## 11. Implementation Documentation Contaminates Interface

**Symptom:** An interface comment describes implementation details that aren't needed by callers.

**Why it increases complexity:** Reveals information that should be hidden. If the implementation changes, the interface comment must also change, even though callers don't care. Creates coupling between interface and implementation.

**Detection pattern:**
```python
def get_user(id):
    """Get user by ID.
    
    Uses the cache-first strategy: checks Redis, then falls back
    to PostgreSQL. Results are cached for 5 minutes.
    """
```

**Fix strategy:** Strip implementation details from interface comments. Describe the contract (what), not the mechanism (how).

---

## 12. Vague Name

**Symptom:** A variable or method name is so imprecise that it doesn't convey useful information.

**Why it increases complexity:** Increases **cognitive load** — readers must decode the meaning from context instead of understanding it from the name.

**Detection pattern:** Names like `data`, `info`, `handle`, `process`, `doStuff`, `tmp`, `val`, `result`, `manager`, `helper`.

**Fix strategy:** Choose names that "create an image" — precise, descriptive, and intuitive. A good name communicates the essence of the thing.

---

## 13. Hard to Pick Name

**Symptom:** You struggle to find a precise, intuitive name for a variable, method, or class.

**Why it increases complexity:** Indicates a design problem, not a naming problem. If you can't name it, you don't understand it well enough.

**Detection pattern:** You find yourself cycling through names, unsatisfied with each. You resort to vague names.

**Fix strategy:** Redesign. The difficulty naming indicates that the concept isn't cleanly defined. Simplify the design until the name becomes obvious.

---

## 14. Hard to Describe

**Symptom:** The documentation for a variable, method, or class must be long in order to be complete.

**Why it increases complexity:** Indicates that the entity is doing too much or its interface is too complex. A design that requires extensive documentation is overcomplicated.

**Detection pattern:** A comment that takes more than 2-3 sentences to fully describe what a method does. A docstring that requires several paragraphs.

**Fix strategy:** Simplify the design. Split the method. Reduce the interface surface. If the concept is inherently complex, reconsider whether it should exist at all.

---

## 15. Nonobvious Code

**Symptom:** The behavior or meaning of code cannot be understood easily by someone reading it for the first time.

**Why it increases complexity:** The highest form of complexity cost — every developer who encounters this code must spend significant mental effort to understand it.

**Detection pattern:** You read a section of code multiple times and still aren't sure what it does. You need to trace through execution mentally. You reach for a debugger to understand the behavior.

**Fix strategy:** Redesign for clarity, not efficiency. If the code requires thought to understand, it's not obvious — redesign. Add comments only after making the code as obvious as possible.
