# Examples

## Before: Tactical patch (Rule 1 violation)

```python
def send_notification(user, message):
    email = EmailService()
    email.connect()
    email.send(user.email, message)
    email.disconnect()
```

The caller does setup and teardown — the module is shallow. A design investment pushes complexity downward:

## After: Deep module (Rule 2)

```python
def send_notification(user, message):
    NotificationService().send(user, message)
```

`NotificationService` handles connection pooling, retries, and format selection. The interface is minimal; the complexity is encapsulated.

## Before: Error handling mirrors happy path (Rule 10 violation)

```python
def get_user(db, user_id):
    try:
        return db.query("SELECT * FROM users WHERE id = ?", user_id)
    except NotFound:
        return None
```

Every caller must handle `None`. The error isn't eliminated — it's deferred.

## After: Error defined out of existence (Rule 10)

```python
def get_user(db, user_id) -> Optional[User]:
    return db.query("SELECT * FROM users WHERE id = ?", user_id).first()
```

The interface returns `Optional[User]` — the "not found" case is a valid state, not an error. Callers don't need try/except for normal flow.

## Creating Your Own Examples

When applying APOSD rules to your code, follow this pattern:
1. Identify the complexity symptom (cognitive load, change amplification, unknown unknowns)
2. Check which rule addresses it (Red Flags section helps here)
3. Encapsulate the complexity behind a stable interface
4. Verify the interface is simpler than what it replaced
