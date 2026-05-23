# Examples

Real-world code examples demonstrating each APOSD principle. Each example shows what agents commonly do wrong and how to fix it with Ousterhout's approach.

*Format inspired by [andrej-karpathy-skills/EXAMPLES.md](https://github.com/multica-ai/andrej-karpathy-skills/blob/main/EXAMPLES.md).*

**Related docs:** [Principles](reference/principles.md) | [Red Flags](reference/red-flags.md) | [Personas](reference/personas.md) | [Scoring](reference/scoring.md)

---

## Contents

- [1. Strategic Over Tactical](#1-strategic-over-tactical)
- [2. Design Deep Modules](#2-design-deep-modules)
- [3. Information Hiding](#3-information-hiding)
- [4. Pull Complexity Downward](#4-pull-complexity-downward)
- [5. Comments First](#5-comments-first)
- [6. Define Errors Out of Existence](#6-define-errors-out-of-existence)
- [7. Better Together or Better Apart](#7-better-together-or-better-apart)
- [8. Design It Twice](#8-design-it-twice)
- [Anti-Patterns Summary](#anti-patterns-summary)
- [Key Insight](#key-insight)

---

## 1. Strategic Over Tactical

### Example: Error handling for a file reader

**User Request:** "Add error handling to the file reader"

**❌ Tactical Approach (Working Code Isn't Enough)**

```python
def read_config(path):
    try:
        with open(path) as f:
            return parse(f.read())
    except FileNotFoundError:
        return {}
    except PermissionError:
        return {}
    except json.JSONDecodeError:
        return {}
```

**Problems:**
- Silently swallows all errors — makes debugging impossible
- Returns `{}` for every failure, indistinguishable from an empty config
- Patching symptoms instead of designing the interface
- Callers can't distinguish "file not found" from "empty config"

**✅ Strategic Approach (Define Errors Out of Existence)**

```python
def read_config(path):
    """Load config from path. Returns Config or raises ConfigError.
    
    The caller doesn't need to know about files or JSON parsing.
    """
    try:
        with open(path) as f:
            return Config(parse(f.read()))
    except (FileNotFoundError, PermissionError, json.JSONDecodeError) as e:
        raise ConfigError(f"Cannot load config from {path}: {e}")

class Config:
    """Application configuration with safe defaults."""
    
    @classmethod
    def defaults(cls):
        return cls({})
```

**Why this is better:**
- Single error type for callers to handle (reduces cognitive load)
- Config class hides implementation details (information hiding)
- Default config is a deliberate design choice, not a swallowed error
- Errors are traceable (no unknown unknowns)

---

[Back to contents](#contents)

## 2. Design Deep Modules

### Example: User data access

**User Request:** "Add a class for accessing user data"

**❌ Shallow Module (Interface as Complex as Implementation)**

```python
class UserRepository:
    def find_by_id(self, id: int) -> Optional[User]:
        return db.query("SELECT * FROM users WHERE id = ?", id)
    
    def find_by_email(self, email: str) -> Optional[User]:
        return db.query("SELECT * FROM users WHERE email = ?", email)
    
    def find_by_name(self, name: str) -> List[User]:
        return db.query("SELECT * FROM users WHERE name LIKE ?", f"%{name}%")
    
    def count_active(self) -> int:
        return db.query("SELECT COUNT(*) FROM users WHERE active = 1")
    
    def count_by_role(self, role: str) -> int:
        return db.query("SELECT COUNT(*) FROM users WHERE role = ?", role)
```

**Problems:**
- Every method is a thin wrapper around a SQL query — shallow
- The interface is as complex as the implementation
- No abstraction: callers must compose these primitives themselves
- Adding a new query means adding a new method

**✅ Deep Module (Simple Interface, Powerful Implementation)**

```python
class UserRepository:
    def find(self, **filters) -> Union[Optional[User], List[User]]:
        """Find users by criteria.
        
        Returns a single User if filtering by unique field (id, email),
        otherwise returns a list. Raises UserNotFound if single match fails.
        
        Examples:
            repo.find(id=1)           -> User or raises
            repo.find(role='admin')   -> [User, ...]
            repo.find(active=True)    -> [User, ...]
            repo.find(name='Al%')     -> [User, ...]  # LIKE match
        """
```

**Why this is better:**
- One method replaces five — simpler interface
- Powerful implementation handles filtering, single vs multi results
- Callers don't need to know about SQL or query construction
- Adding new filter criteria doesn't change the interface
- The interface is much simpler than the implementation (deep)

---

## 3. Information Hiding

### Example: HTTP parameter handling

**User Request:** "Parse HTTP query parameters"

**❌ Information Leakage (Implementation Details in Interface)**

```python
class Request:
    def get_parameter(self, name: str) -> str:
        """Get query parameter from URL.
        
        Uses urllib.parse.parse_qs internally.
        Returns the first value if multiple values exist.
        Returns empty string if parameter is missing.
        """
        parsed = urllib.parse.urlparse(self.url)
        params = urllib.parse.parse_qs(parsed.query)
        values = params.get(name, [])
        return values[0] if values else ""
```

**Problems:**
- The docstring reveals the implementation (urllib.parse)
- Callers now know about internals — if the implementation changes, the contract is coupled
- The actual behavior (first value, empty string) is more important than the tools used

**✅ Information Hiding (What, Not How)**

```python
class Request:
    def get_parameter(self, name: str) -> str:
        """Get the value of a query parameter.
        
        Returns the parameter value if present, or empty string.
        If a parameter appears multiple times, returns the first value.
        """
```

**Why this is better:**
- Interface only reveals the contract, not the implementation
- Can switch from `urlparse` to regex to hand-parsed without changing callers
- The complexity of URL parsing is hidden inside the module

---

## 4. Pull Complexity Downward

### Example: Text editor undo

**User Request:** "Implement undo for a text editor"

**❌ Complexity Exposed to Caller**

```python
class TextEditor:
    def insert(self, pos: int, text: str):
        # Insert text at position
        self.text = self.text[:pos] + text + self.text[pos:]
        # Caller must handle undo bookkeeping
        return ('delete', pos, len(text))  # undo action returned to caller
```

Every caller must now track undo actions:

```python
# Every caller needs undo handling
editor = TextEditor()
actions = []
result = editor.insert(5, "hello")
actions.append(result)  # Caller manages undo stack
```

**✅ Complexity Pulled Downward**

```python
class TextEditor:
    def __init__(self):
        self.text = ""
        self._undo_stack = []
    
    def insert(self, pos: int, text: str):
        self.text = self.text[:pos] + text + self.text[pos:]
        self._undo_stack.append(('delete', pos, len(text)))
    
    def undo(self):
        if not self._undo_stack:
            return
        action, pos, length = self._undo_stack.pop()
        if action == 'delete':
            end = pos + length
            self.text = self.text[:pos] + self.text[end:]
```

**Why this is better:**
- Callers just call `insert()` and `undo()` — the common case is trivial
- The complexity of undo bookkeeping is hidden in the implementation
- Callers don't need to know about undo stacks or action tuples
- The interface is simple (two methods), the implementation handles the complexity

---

## 5. Comments First

### Example: Build a module interface

**User Request:** "Create a rate limiter module"

**❌ Code First, Comments After (or Never)**

```python
class RateLimiter:
    def __init__(self, limit, window):
        self.limit = limit
        self.window = window
        self.buckets = {}
    
    def check(self, key):
        now = time.time()
        if key not in self.buckets:
            self.buckets[key] = []
        self.buckets[key] = [t for t in self.buckets[key] if now - t < self.window]
        if len(self.buckets[key]) >= self.limit:
            return False
        self.buckets[key].append(now)
        return True
```

**Problems:**
- No interface documentation — what do `limit` and `window` mean? Units?
- What does `check` return? True = allowed? True = blocked?
- What happens if `window` is 0? Or negative?
- Callers must read the implementation to understand the contract

**✅ Comments First (Interface Before Implementation)**

```python
class RateLimiter:
    """Controls request rate within a sliding time window.
    
    Typical usage:
        limiter = RateLimiter(max_requests=100, window_seconds=60)
        if limiter.allow("user:42"):
            process_request()
        else:
            return 429
    
    The limiter tracks each key independently and automatically
    expires old entries from the window.
    """
    
    def allow(self, key: str) -> bool:
        """Check if this key has exceeded the rate limit.
        
        Returns True if the request should be allowed.
        Records this check as a request in the current window.
        """
```

**Why this is better:**
- Interface is designed before implementation — forces thinking about the API
- Comments describe what's not obvious from the signature (units, thread-safety, return value semantics)
- A hard-to-write comment here would signal a design problem early

---

## 6. Define Errors Out of Existence

### Example: Windows file deletion

**User Request:** "Implement a file deletion function"

**❌ Error Propagation (Caller Handles Everything)**

```python
def delete_file(path):
    """Delete a file. Raises various exceptions."""
    try:
        os.remove(path)
    except PermissionError:
        raise
    except FileNotFoundError:
        raise
    except OSError:
        raise
```

Callers must handle every case:

```python
try:
    delete_file("/tmp/data.txt")
except PermissionError:
    log("Can't delete — permissions")
except FileNotFoundError:
    log("Already deleted")
except OSError:
    log("Something else went wrong")
```

**✅ Errors Defined Out of Existence**

```python
def delete_file(path):
    """Delete a file if it exists.
    
    Success means the file no longer exists at the given path
    after this call, regardless of whether it existed before.
    Raises PermissionError if the file exists but cannot be removed.
    """
    try:
        os.remove(path)
    except FileNotFoundError:
        pass  # Already gone — that's success
    except PermissionError:
        raise  # Caller needs to know this
```

**Why this is better:**
- "File not found" is defined out of existence — it's not an error anymore
- The most common callers (cleanup, temp file removal) don't need try/catch
- Only PermissionError is a real error here — and it's declared in the contract
- Unexpected OS failures still surface instead of being hidden

---

## 7. Better Together or Better Apart

### Example: Logging class

**User Request:** "Add logging to the application"

**❌ Split When Should Be Together (Conjoined Methods)**

```python
class LogWriter:
    def write(self, message):
        with open("app.log", "a") as f:
            f.write(message + "\n")

class LogFormatter:
    def format(self, level, message):
        return f"[{level}] {message}"

class LogFilter:
    def should_log(self, level):
        return level >= self.min_level
```

Every caller uses all three together:

```python
writer = LogWriter()
formatter = LogFormatter()
filter = LogFilter()
if filter.should_log("INFO"):
    writer.write(formatter.format("INFO", "User logged in"))
```

**Problems:**
- These classes are always used together — conjoined
- Each is shallow (trivial implementation, complex interface for what they do)
- Callers must manage three objects to do one thing
- High cognitive load from unnecessary splitting

**✅ Together (Deep Module)**

```python
class Logger:
    def __init__(self, min_level="INFO"):
        self.min_level = min_level
    
    def log(self, level, message):
        if self._should_log(level):
            self._write(f"[{level}] {message}")
    
    def info(self, message):
        self.log("INFO", message)
    
    def error(self, message):
        self.log("ERROR", message)
    
    def _should_log(self, level):
        levels = {"DEBUG": 0, "INFO": 1, "WARN": 2, "ERROR": 3}
        return levels.get(level, 1) >= levels.get(self.min_level, 1)
    
    def _write(self, formatted):
        with open("app.log", "a") as f:
            f.write(formatted + "\n")

# Usage
log = Logger()
log.info("User logged in")
```

**Why this is better:**
- One class instead of three — simpler interface
- Implementation details (format, write, filter) are hidden inside
- Callers use one object with one method — trivial common case
- Not conjoined: you can understand `log()` without reading `_should_log()`

---

## 8. Design It Twice

### Example: Cache module

**User Request:** "Design a caching layer"

**First Design (Temporal Decomposition — Based on Execution Order)**

```python
class Cache:
    def check_cache(self, key):
        return self._storage.get(key)
    
    def fetch_from_source(self, key):
        data = self._source.get(key)
        self._store_in_cache(key, data)
        return data
    
    def _store_in_cache(self, key, data):
        self._storage[key] = data
```

**Problems:**
- Methods mirror the execution order (check → fetch → store)
- No abstraction — callers must orchestrate the sequence
- Information leaks between methods

**Second Design (Abstraction-Based)**

```python
class Cache:
    def get(self, key):
        """Get value for key. Fetches and caches on miss."""
        if key in self._storage:
            return self._storage[key]
        value = self._source.fetch(key)
        self._storage[key] = value
        return value
```

**Why the second is better:**
- Single method replaces three — deep interface
- The "check then fetch then store" sequence is hidden inside
- Callers just call `get()` — the common case is trivial
- Future changes (eviction, TTL, prefetching) don't affect the interface

---

## Anti-Patterns Summary

| Principle | Anti-Pattern | Fix |
|-----------|-------------|-----|
| Strategic Over Tactical | Swallow errors to "make it work" | Design the interface first, then handle errors deliberately |
| Deep Modules | Five one-line methods instead of one expressive method | Merge into a single method with a powerful interface |
| Information Hiding | Docstring reveals urllib.parse usage | Document the contract, not the implementation |
| Pull Complexity Downward | Undo bookkeeping returned to caller | Push undo stack into the implementation |
| Comments First | Class with no interface documentation | Draft the interface comment before writing the body |
| Define Errors Out of Existence | Every call is wrapped in try/catch | Design the interface so common errors can't happen |
| Better Together or Better Apart | Three shallow classes used together | Merge into one class with hidden detail |
| Design It Twice | Methods mirror execution order | Design around abstractions, not execution sequence |

## Key Insight

The "bad" examples aren't obviously wrong — they reflect common instincts. The problem is **shallow design**: interfaces that expose complexity instead of hiding it.

The "good" versions are:
- Simpler to use (callers do less work)
- Harder to misuse (fewer ways to get it wrong)
- Easier to change (implementation can change without affecting callers)
- More obvious (you can understand the module without reading its internals)

**Good design is code that hides complexity, not code that handles complexity.**
