# Examples

Real-world code examples demonstrating each APOSD principle. Each example shows what agents commonly do wrong and how to fix it with Ousterhout's approach.

*Format inspired by [andrej-karpathy-skills/EXAMPLES.md](https://github.com/multica-ai/andrej-karpathy-skills/blob/main/EXAMPLES.md).*

**Related docs:** [Principles](skills/aposd/references/principles.md) | [Red Flags](skills/aposd-critique/references/red-flags.md) | [Personas](skills/aposd-critique/references/personas.md) | [Scoring](skills/aposd/references/scoring.md) *(used by `aposd audit`)*

---

## Contents

- [1. Strategic Over Tactical](#1-strategic-over-tactical)
- [2. Design Deep Modules](#2-design-deep-modules)
- [3. Information Hiding](#3-information-hiding)
- [4. Design General-Purpose Modules](#4-design-general-purpose-modules)
- [5. Different Layer, Different Abstraction](#5-different-layer-different-abstraction)
- [6. Pull Complexity Downward](#6-pull-complexity-downward)
- [7. Comments First](#7-comments-first)
- [8. Choosing Names](#8-choosing-names)
- [9. Design for Reading](#9-design-for-reading)
- [10. Define Errors Out of Existence](#10-define-errors-out-of-existence)
- [11. Better Together or Better Apart](#11-better-together-or-better-apart)
- [12. Design It Twice](#12-design-it-twice)
- [13. Design for the Future](#13-design-for-the-future)
- [14. Increments Are Abstractions](#14-increments-are-abstractions)
- [15. Modify Strategically](#15-modify-strategically)
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

## 4. Design General-Purpose Modules

### Example: Notification sending

**User Request:** "Send a welcome email after signup"

**❌ Special-Purpose (Serves One Caller)**

```python
def send_welcome_email(user):
    send_email(user.email, "Welcome!", "Thanks for signing up!")

def send_password_reset(user):
    send_email(user.email, "Reset", "Click here to reset")

def send_order_confirmation(user, order):
    send_email(user.email, "Order", f"Order #{order.id} confirmed")
```

**Problems:**
- Three nearly identical functions — each is a shallow wrapper around `send_email`
- Adding a new notification type means adding another function
- Callers can't customize subject or body without a new function
- The interface is as complex as the implementation (shallow)

**✅ General-Purpose (Deep Interface, Multiple Use Cases)**

```python
def notify(recipient, subject, body, template=None):
    """Send a notification. Returns delivery status.
    
    Args:
        recipient: email address or user object
        subject: notification subject line
        body: plain text body, or template name if template is set
        template: optional template name for formatting
    """
    email = recipient.email if hasattr(recipient, "email") else recipient
    if template:
        body = render_template(template, body=body)
    return send_email(email, subject, body)

# Usage — same function serves every caller
notify(user, "Welcome!", "Thanks for signing up!", template="welcome")
notify(user, "Reset", reset_link, template="password_reset")
notify(user, "Order", f"Order #{order.id} confirmed")
```

**Why this is better:**
- One function replaces many — simpler interface
- Supports templates as an option without adding new functions
- New notification types don't require new code
- The implementation is richer than the interface (deep)

---

[Back to contents](#contents)

## 5. Different Layer, Different Abstraction

### Example: Order processing pipeline

**User Request:** "Add an order processing pipeline"

**❌ Pass-Through Chain (Each Layer Adds Nothing)**

```python
class OrderController:
    def process_order(self, request):
        return self.service.process(request.body)

class OrderService:
    def process(self, data):
        return self.repo.save(data)

class OrderRepo:
    def save(self, data):
        return database.insert("orders", data)
```

**Problems:**
- Every layer is a pass-through — same abstraction, same signature, no value added
- Removing `OrderService` changes nothing for the caller
- A reader must trace through all three to find the real implementation
- Adding behavior means changing all three layers

**✅ Different Abstractions (Each Layer Adds Value)**

```python
class OrderController:
    def handle(self, request):
        """Parse request, delegate to service, return HTTP response."""
        return self.service.place_order(request.json())

class OrderService:
    def place_order(self, items):
        """Validate inventory, apply pricing, persist order."""
        validated = self.inventory.check(items)
        total = self.pricing.calculate(validated)
        return self.repo.create(validated, total)

class OrderRepo:
    def create(self, items, total):
        """Persist order and return order ID."""
        return database.insert("orders", {"items": items, "total": total})
```

**Why this is better:**
- Each layer has a distinct responsibility (HTTP → business logic → persistence)
- Removing any layer would force its logic into another, changing abstractions
- A reader can understand each layer independently
- Each layer adds value the caller doesn't see

---

## 6. Pull Complexity Downward

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

[Back to contents](#contents)

## 7. Comments First

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
- Comments describe what's not obvious from the signature (per-key behavior, window semantics, return value semantics)
- A hard-to-write comment here would signal a design problem early

---

[Back to contents](#contents)

## 8. Choosing Names

### Example: HTTP client configuration

**User Request:** "Set up the HTTP client configuration"

**❌ Vague Names (Requires Mental Decoding)**

```python
class HttpClient:
    def __init__(self, data):
        self.data = data
    
    def process(self, handle, info):
        tmp = self.data.get(handle)
        result = tmp.do_thing(info)
        return result
```

**Problems:**
- `data`, `handle`, `info`, `tmp`, `result`, `process` — none convey meaning
- Every reader must trace the implementation to understand what each thing is
- Changing behavior requires reading the full method body
- A bug at the call site is invisible because the names don't constrain intent

**✅ Precise Names (Create an Image)**

```python
class HttpClient:
    def __init__(self, config):
        self.config = config
    
    def send_request(self, endpoint, payload):
        route = self.config.get_route(endpoint)
        response = route.execute(payload)
        return response
```

**Why this is better:**
- Every name creates an image: `config`, `endpoint`, `payload`, `route`, `response`
- The call site `client.send_request("/users", {"id": 42})` reads like intent
- No mental decoding needed — the names tell the story
- Consistent vocabulary across the module reduces cognitive load

---

[Back to contents](#contents)

## 9. Design for Reading

### Example: Permission checking logic

**User Request:** "Check if a user can edit a document"

**❌ Nonobvious Code (Requires Mental Execution)**

```python
def can_edit(user, doc):
    if not user:
        return False
    if user.role == "admin":
        return True
    if doc.owner_id == user.id:
        return True
    if user.role == "editor" and doc.status != "archived":
        return True
    if doc.shared_with and user.id in doc.shared_with:
        return True
    return False
```

**Problems:**
- Reader must trace all 5 conditions to understand the logic
- No indication which rules take priority
- Adding a new permission rule requires reading the full chain
- The "what" is hidden behind a wall of `if` statements

**✅ Obvious Code (Design for Reading)**

```python
def can_edit(user, doc):
    if not user:
        return False
    is_admin = user.role == "admin"
    is_owner = doc.owner_id == user.id
    is_editor = user.role == "editor" and doc.status != "archived"
    is_shared = doc.shared_with and user.id in doc.shared_with
    return is_admin or is_owner or is_editor or is_shared
```

**Why this is better:**
- The conditions are named — a reader sees "is_admin" not a raw role comparison
- The return statement reads like a sentence: "allowed if admin or owner or editor or shared"
- Adding a new rule means adding one named variable and one clause
- No mental execution required — the intent is obvious at a glance

---

[Back to contents](#contents)

## 10. Define Errors Out of Existence

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

## 11. Better Together or Better Apart

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

## 12. Design It Twice

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

[Back to contents](#contents)

## 13. Design for the Future

### Example: Configuration module

**User Request:** "Add a configuration module for the application"

**❌ Over-Engineering for Hypotheticals**

```python
class Config:
    def __init__(self, source="file", format="yaml", cache_ttl=300,
                 fallback=None, encryption=False, schema=None):
        self.source = source
        self.format = format
        self.cache_ttl = cache_ttl
        self.fallback = fallback
        self.encryption = encryption
        self.schema = schema
        # ... dozens of lines setting up unused features
```

**Problems:**
- Constructor has 7 parameters for hypothetical future needs (encryption, schema validation, multiple sources)
- Only one source (file) and one format (YAML) are ever used
- Every reader must understand all 7 parameters to use the class
- Complexity added for futures that never arrived

**✅ Encapsulate What's Known, Add When Needed**

```python
class Config:
    def __init__(self, path):
        self.path = path
        self._data = {}
    
    def load(self):
        with open(self.path) as f:
            self._data = yaml.safe_load(f)
    
    def get(self, key, default=None):
        return self._data.get(key, default)
```

**Why this is better:**
- Interface captures only the current need — one parameter, three methods
- Adding encryption or schema validation later doesn't change callers (information hiding)
- No speculative complexity burdening every reader
- The implementation can grow without interface changes

---

[Back to contents](#contents)

## 14. Increments Are Abstractions

### Example: Text formatting toolbar

**User Request:** "Add bold, italic, and underline buttons to the editor"

**❌ Feature Slicing (Decompose by Execution Order)**

```python
# Sprint 1: Add bold button
class BoldButton:
    def on_click(self):
        self.editor.wrap_selection("<b>", "</b>")

# Sprint 2: Add italic button (copy-paste from bold)
class ItalicButton:
    def on_click(self):
        self.editor.wrap_selection("<i>", "</i>")

# Sprint 3: Add underline button (copy-paste again)
class UnderlineButton:
    def on_click(self):
        self.editor.wrap_selection("<u>", "</u>")
```

**Problems:**
- Each sprint produces a nearly identical class — three times the code
- Adding a new formatting option means copy-pasting the same pattern again
- The formatting logic is leaked into every button class
- No abstraction boundary — changes to formatting ripple across all buttons

**✅ Abstraction Slicing (Decompose by Abstraction)**

```python
# Sprint 1: Build the formatting abstraction
class TextFormatter:
    def apply(self, editor, tag):
        editor.wrap_selection(f"<{tag}>", f"</{tag}>")

# Sprint 2+: Build buttons on top of the abstraction
class BoldButton:
    def on_click(self):
        self.formatter.apply(self.editor, "b")

class ItalicButton:
    def on_click(self):
        self.formatter.apply(self.editor, "i")

class UnderlineButton:
    def on_click(self):
        self.formatter.apply(self.editor, "u")
```

**Why this is better:**
- The first increment produces the abstraction layer (reusable on its own)
- Each button is 1-2 lines, not a copy-paste of formatting logic
- Adding a new button (strikethrough, superscript) adds no new formatting code
- The formatting abstraction is a deep module — simple interface, powerful implementation

---

[Back to contents](#contents)

## 15. Modify Strategically

### Example: Fixing a validation bug

**User Request:** "Fix the email validation — it accepts invalid addresses"

**❌ Tactical Patch (Fix the Symptom, Leave the Rot)**

```python
def validate_user(data):
    errors = []
    if not data.get("name"):
        errors.append("Name required")
    if not data.get("email"):
        errors.append("Email required")
    # TODO: fix email regex later
    if "@" not in data.get("email", ""):
        errors.append("Invalid email")
    if data.get("age", 0) < 0:
        errors.append("Age must be positive")
    return errors
```

**Problems:**
- The fix adds a naive `@` check but leaves the `# TODO` from a prior tactical patch
- No cleanup of the surrounding code — the `age` check is still using a bare `0` default instead of a named constant
- The `name` and `email` required checks duplicate the same pattern manually
- Leaves the module in worse shape than it was found

**✅ Strategic Fix (Improve the Surrounding Code)**

```python
MIN_AGE = 0

def validate_user(data):
    errors = []
    _validate_required(data, "name", errors)
    _validate_required(data, "email", errors)
    _validate_email(data.get("email", ""), errors)
    if data.get("age", MIN_AGE) < MIN_AGE:
        errors.append("Age must be positive")
    return errors

def _validate_required(data, field, errors):
    if not data.get(field):
        errors.append(f"{field.title()} required")

def _validate_email(email, errors):
    if not email or "@" not in email or "." not in email.split("@")[-1]:
        errors.append("Invalid email")
```

**Why this is better:**
- The `# TODO` is removed — the fix is done properly, not deferred
- Repeated required-field checks are extracted into a shared helper (reduces duplication)
- The `age` check now uses a named constant instead of a magic `0`
- The email validation is extracted and improved — not just patched
- Future changes to required-field logic change one method, not every call site
- The module is cleaner after the fix than before

---

## Anti-Patterns Summary

| Principle | Anti-Pattern | Fix |
|-----------|-------------|-----|
| Strategic Over Tactical | Swallow errors to "make it work" | Design the interface first, then handle errors deliberately |
| Deep Modules | Five one-line methods instead of one expressive method | Merge into a single method with a powerful interface |
| Information Hiding | Docstring reveals urllib.parse usage | Document the contract, not the implementation |
| General-Purpose Modules | Three nearly identical notification functions | Generalize into one function with options |
| Different Layer, Different Abstraction | Pass-through chain: Controller → Service → Repo | Give each layer a distinct responsibility |
| Pull Complexity Downward | Undo bookkeeping returned to caller | Push undo stack into the implementation |
| Comments First | Class with no interface documentation | Draft the interface comment before writing the body |
| Choosing Names | Vague names `data`, `handle`, `info`, `tmp` | Name each thing for what it is |
| Design for Reading | Wall of conditionals requiring mental execution | Extract named variables that read like a sentence |
| Define Errors Out of Existence | Every call is wrapped in try/catch | Design the interface so common errors can't happen |
| Better Together or Better Apart | Three shallow classes used together | Merge into one class with hidden detail |
| Design It Twice | Methods mirror execution order | Design around abstractions, not execution sequence |
| Design for the Future | Constructor with 7 parameters for hypotheticals | Start with what's needed, add when proven |
| Increments Are Abstractions | Each button class copy-pastes formatting logic | Build the abstraction layer first |
| Modify Strategically | Patch the bug, leave the TODO | Fix the surrounding code too — leave it cleaner |

## Key Insight

The "bad" examples aren't obviously wrong — they reflect common instincts. The problem is **shallow design**: interfaces that expose complexity instead of hiding it.

The "good" versions are:
- Simpler to use (callers do less work)
- Harder to misuse (fewer ways to get it wrong)
- Easier to change (implementation can change without affecting callers)
- More obvious (you can understand the module without reading its internals)

**Good design is code that hides complexity, not code that handles complexity.**
