"""
Error-eliminating decorator

Wrap a fallible API so callers never see the error case.

APOSD: Rule 10 (Define Errors Out of Existence)
"""

from __future__ import annotations
from functools import wraps
from typing import Any, Callable, TypeVar

F = TypeVar("F", bound=Callable[..., Any])


def suppress(exc: type[Exception] | tuple[type[Exception], ...],
             default: Any = None) -> Callable[[F], F]:
    """Return a decorator that replaces *exc* with a default value."""
    def decorator(func: F) -> F:
        @wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> Any:
            try:
                return func(*args, **kwargs)
            except exc:
                return default
        return wrapper  # type: ignore[return-value]
    return decorator
