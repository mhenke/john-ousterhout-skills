"""
Deep module scaffold

Hide connection lifecycle, error handling, and retry logic
behind a one-line interface.

APOSD: Rule 2 (Deep Modules) + Rule 6 (Pull Complexity Downward)
"""

from __future__ import annotations
import logging
from typing import Any, Protocol


class EmailService(Protocol):
    def send(self, to: str, subject: str, body: str) -> None: ...


class SmtpEmailService:
    """Send emails with automatic connection pooling and retry."""

    def __init__(self, host: str, port: int, timeout: int = 30) -> None:
        self._host = host
        self._port = port
        self._timeout = timeout
        self._pool: list[Connection] = []

    def send(self, to: str, subject: str, body: str) -> None:
        """Deliver an email. Handles connect/send/disconnect internally."""
        conn = self._acquire()
        try:
            conn.send(to, subject, body)
        finally:
            self._release(conn)

    def _acquire(self) -> Connection:
        return self._pool.pop() if self._pool else Connection(
            self._host, self._port, self._timeout
        )

    def _release(self, conn: Connection) -> None:
        if conn.healthy and len(self._pool) < 5:
            self._pool.append(conn)
        else:
            conn.close()
