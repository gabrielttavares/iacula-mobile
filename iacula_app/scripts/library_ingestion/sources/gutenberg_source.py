from __future__ import annotations

from .base_source import BaseSource, SourceDescriptor


class GutenbergSource(BaseSource):
    descriptor = SourceDescriptor(id="gutenberg", rank="B")
