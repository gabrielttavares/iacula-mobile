from __future__ import annotations

import re
import unicodedata
from typing import Any


def _normalize_text(value: str) -> str:
    text = unicodedata.normalize("NFC", value)
    text = text.replace("\u00a0", " ")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def normalize_catalog(manifest: dict[str, Any]) -> dict[str, Any]:
    normalized = dict(manifest)

    authors = manifest.get("authors", [])
    works = manifest.get("works", [])

    normalized_authors: list[dict[str, Any]] = []
    for author in authors:
        normalized_authors.append(
            {
                **author,
                "id": _normalize_text(str(author.get("id", ""))),
                "name": _normalize_text(str(author.get("name", ""))),
                "description": _normalize_text(str(author.get("description", ""))),
            }
        )

    normalized_works: list[dict[str, Any]] = []
    for work in works:
        normalized_works.append(
            {
                **work,
                "id": _normalize_text(str(work.get("id", ""))),
                "title": _normalize_text(str(work.get("title", ""))),
                "author": _normalize_text(str(work.get("author", ""))),
                "author_id": _normalize_text(str(work.get("author_id", ""))),
                "description": _normalize_text(str(work.get("description", ""))),
                "source_rank": _normalize_text(str(work.get("source_rank", ""))),
            }
        )

    normalized["authors"] = normalized_authors
    normalized["works"] = normalized_works
    return normalized
