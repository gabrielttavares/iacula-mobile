from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class SourceDescriptor:
    id: str
    rank: str


class BaseSource:
    descriptor: SourceDescriptor
