from __future__ import annotations

from .base_source import BaseSource, SourceDescriptor


class EscrivaSource(BaseSource):
    descriptor = SourceDescriptor(id="escriva_api", rank="A")
