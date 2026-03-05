#!/usr/bin/env python3
from __future__ import annotations

import re
import unicodedata
from typing import Any


def _normalize_text(value: str) -> str:
    text = unicodedata.normalize("NFC", value)
    text = text.replace("\u00a0", " ")
    text = text.replace("\u200b", "")
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def _normalize_paragraphs(paragraphs: list[str]) -> list[str]:
    output: list[str] = []
    for paragraph in paragraphs:
        normalized = _normalize_text(paragraph)
        if normalized:
            output.append(normalized)
    return output


def normalize_books(raw_books: list[dict[str, Any]]) -> list[dict[str, Any]]:
    normalized_books: list[dict[str, Any]] = []

    for book in raw_books:
        normalized_chapters: list[dict[str, Any]] = []
        for chapter in book.get("chapters", []):
            if chapter.get("kind") == "intro":
                normalized_chapters.append(
                    {
                        "slug": chapter.get("slug"),
                        "title": _normalize_text(chapter.get("title", "")),
                        "kind": "intro",
                        "paragraphs": _normalize_paragraphs(chapter.get("paragraphs", [])),
                    }
                )
                continue

            normalized_sections: list[dict[str, Any]] = []
            for section in chapter.get("sections", []):
                normalized_sections.append(
                    {
                        "number": section.get("number"),
                        "title": _normalize_text(section.get("title", "")),
                        "paragraphs": _normalize_paragraphs(section.get("paragraphs", [])),
                    }
                )

            normalized_chapters.append(
                {
                    "slug": chapter.get("slug"),
                    "title": _normalize_text(chapter.get("title", "")),
                    "kind": chapter.get("kind", "points"),
                    "sections": normalized_sections,
                }
            )

        normalized_books.append(
            {
                "id": book.get("id"),
                "book_id": book.get("book_id"),
                "title": _normalize_text(book.get("title", "")),
                "author": _normalize_text(book.get("author", "")),
                "group": book.get("group"),
                "chapters": normalized_chapters,
            }
        )

    return normalized_books
