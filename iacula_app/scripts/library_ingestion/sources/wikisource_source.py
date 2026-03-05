from __future__ import annotations

from .base_source import BaseSource, SourceDescriptor


class WikisourceSource(BaseSource):
    descriptor = SourceDescriptor(id="wikisource", rank="B")
