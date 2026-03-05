#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

BOOK_ORDER = [
    "caminho",
    "sulco",
    "forja",
    "e-cristo-que-passa",
    "amigos-de-deus",
    "santo-rosario",
    "via-sacra",
    "em-dialogo-com-o-senhor",
]

HOMILY_BOOKS = {
    "e-cristo-que-passa",
    "amigos-de-deus",
    "em-dialogo-com-o-senhor",
}


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp_path = path.with_suffix(".tmp")
    temp_path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    temp_path.replace(path)


def _to_export_payload(book: dict[str, Any]) -> dict[str, Any]:
    chapters = book.get("chapters", [])
    book_id = book.get("id")

    exported_chapters: list[dict[str, Any]] = []
    for chapter in chapters:
        if chapter.get("kind") == "intro":
            exported_chapters.append(
                {
                    "slug": chapter.get("slug"),
                    "title": chapter.get("title"),
                    "kind": "intro",
                    "paragraphs": chapter.get("paragraphs", []),
                }
            )
            continue

        sections = chapter.get("sections", [])
        if book_id in HOMILY_BOOKS:
            exported_chapters.append(
                {
                    "slug": chapter.get("slug"),
                    "title": chapter.get("title"),
                    "kind": "homily",
                    "numberedSections": [
                        {
                            "number": section.get("number"),
                            "paragraphs": section.get("paragraphs", []),
                        }
                        for section in sections
                    ],
                    "paragraphs": [],
                }
            )
            continue

        exported_chapters.append(
            {
                "slug": chapter.get("slug"),
                "title": chapter.get("title"),
                "kind": chapter.get("kind", "points"),
                "sections": [
                    {
                        "number": section.get("number"),
                        "title": section.get("title") or None,
                        "paragraphs": section.get("paragraphs", []),
                    }
                    for section in sections
                ],
            }
        )

    return {
        "id": book_id,
        "title": book.get("title"),
        "author": book.get("author"),
        "type": "homilies" if book_id in HOMILY_BOOKS else "points",
        "chapters": exported_chapters,
    }


def export_books(normalized_books: list[dict[str, Any]], output_dir: Path) -> None:
    by_id = {book["id"]: book for book in normalized_books}

    index_books: list[dict[str, Any]] = []
    for book_id in BOOK_ORDER:
        book = by_id.get(book_id)
        if book is None:
            continue

        asset_path = f"assets/books/escriva/{book_id}.json"
        export_payload = _to_export_payload(book)
        _write_json(output_dir / f"{book_id}.json", export_payload)

        index_books.append(
            {
                "id": book_id,
                "title": book.get("title"),
                "author": book.get("author"),
                "description": "Leituras de São Josemaría Escrivá",
                "type": export_payload["type"],
                "assetPath": asset_path,
                "chapters": [
                    {
                        "slug": chapter.get("slug"),
                        "title": chapter.get("title"),
                        "kind": chapter.get("kind", "points"),
                    }
                    for chapter in export_payload.get("chapters", [])
                ],
            }
        )

    _write_json(output_dir / "index.json", {"books": index_books})
