from __future__ import annotations

import json
import re
import subprocess
import tempfile
import time
import urllib.request
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError


_NOISE_PARAGRAPH_PATTERNS = (
    re.compile(r"^\d{1,3}$"),
    re.compile(r"^\d+\s*\n\s*\d+$"),
    re.compile(r"^_{3,}$"),
    re.compile(r"^cf\.\s", re.IGNORECASE),
    re.compile(r"^[^\n]{0,120}\s[–-]\s[^\n]{0,120}$"),
    re.compile(r"^[A-Za-zÀ-ÿ'’\s]+\d{1,3}:\s*\d", re.IGNORECASE),
)


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp_path = path.with_suffix(".tmp")
    temp_path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    temp_path.replace(path)


def _fetch_url_bytes(
    url: str,
    *,
    retries: int = 6,
    retry_delay_seconds: float = 1.5,
) -> bytes:
    last_error: Exception | None = None
    for attempt in range(retries):
        request = urllib.request.Request(
            url,
            headers={"User-Agent": "iacula-library-ingestion/1.0"},
        )
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                return response.read()
        except HTTPError as exc:
            last_error = exc
            is_transient_http = exc.code in {401, 429, 500, 502, 503, 504}
            has_next_attempt = attempt + 1 < retries
            if not (is_transient_http and has_next_attempt):
                raise
            time.sleep(retry_delay_seconds * (attempt + 1))
        except URLError as exc:
            last_error = exc
            has_next_attempt = attempt + 1 < retries
            if not has_next_attempt:
                raise
            time.sleep(retry_delay_seconds * (attempt + 1))

    if last_error is not None:
        raise last_error

    raise RuntimeError(f"failed to fetch URL: {url}")


def _fetch_text(url: str) -> str:
    payload = _fetch_url_bytes(url).decode("utf-8", "ignore")
    return payload


def _fetch_pdf_text(url: str) -> str:
    payload = _fetch_url_bytes(url)

    with tempfile.TemporaryDirectory() as tmpdir:
        pdf_path = Path(tmpdir) / "source.pdf"
        text_path = Path(tmpdir) / "source.txt"
        pdf_path.write_bytes(payload)
        subprocess.run(
            ["/opt/homebrew/bin/pdftotext", "-enc", "UTF-8", str(pdf_path), str(text_path)],
            check=True,
        )
        return text_path.read_text(encoding="utf-8", errors="ignore")


def _split_plain_text_into_chapters(text: str) -> list[dict[str, object]]:
    normalized = text.replace("\r\n", "\n")
    normalized = re.sub(r"\n{3,}", "\n\n", normalized)

    chapter_regex = re.compile(
        r"^((?:CAP[IÍ]TULO\s+[IVXLCDM0-9]+|LIVRO\s+[IVXLCDM0-9]+|[IVXLCDM0-9]+\s+LIVRO)(?:\s*[-–:]\s*.*)?)$",
        re.MULTILINE | re.IGNORECASE,
    )
    matches = list(chapter_regex.finditer(normalized))

    if not matches:
        paragraphs = _clean_paragraphs([p for p in normalized.split("\n\n") if p.strip()])
        return [
            {
                "slug": "texto-integral",
                "title": "Texto integral",
                "kind": "chapter",
                "sections": [
                    {
                        "number": 1,
                        "title": "Texto",
                        "paragraphs": paragraphs,
                    }
                ],
            }
        ]

    chapters: list[dict[str, object]] = []
    for index, match in enumerate(matches):
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(normalized)
        title = match.group(1).strip().title()
        body = normalized[start:end].strip()
        paragraphs = _clean_paragraphs([p for p in body.split("\n\n") if p.strip()])
        slug = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")
        chapters.append(
            {
                "slug": slug or f"capitulo-{index + 1}",
                "title": title,
                "kind": "chapter",
                "sections": [
                    {
                        "number": index + 1,
                        "title": title,
                        "paragraphs": paragraphs,
                    }
                ],
            }
        )

    return chapters


def _is_noise_paragraph(paragraph: str) -> bool:
    stripped = paragraph.strip()
    if not stripped:
        return True
    for pattern in _NOISE_PARAGRAPH_PATTERNS:
        if pattern.match(stripped):
            return True
    return False


def _normalize_paragraph(paragraph: str) -> str:
    normalized = paragraph.replace("\r\n", "\n")
    normalized = re.sub(r"^\d{1,3}\s*\n", "", normalized)
    normalized = re.sub(r"([A-Za-zÀ-ÿ])\d{1,2}\b", r"\1", normalized)
    normalized = re.sub(r"\s+", " ", normalized)
    normalized = re.sub(r"\s\d{1,3}(?=[\.!?]?$)", "", normalized)
    return normalized.strip()


def _clean_paragraphs(paragraphs: list[str]) -> list[str]:
    cleaned: list[str] = []
    for paragraph in paragraphs:
        normalized = _normalize_paragraph(paragraph)
        if _is_noise_paragraph(normalized):
            continue

        if cleaned and cleaned[-1].endswith("-"):
            cleaned[-1] = f"{cleaned[-1][:-1]}{normalized}"
        else:
            cleaned.append(normalized)

    return cleaned


def export_catalog_assets(
    *,
    manifest: dict[str, Any],
    source_registry: dict[str, object],
    output_dir: Path,
) -> None:
    del source_registry

    authors = manifest.get("authors", [])
    works = manifest.get("works", [])
    generated_works: dict[str, dict[str, Any]] = {}
    works_by_author: dict[str, list[dict[str, Any]]] = {}

    for work in works:
        mutable_work = dict(work)
        source_text_url = str(mutable_work.get("source_text_url", "")).strip()
        source_pdf_url = str(mutable_work.get("source_pdf_url", "")).strip()
        if (source_text_url or source_pdf_url) and mutable_work.get("available") is True:
            generated_path = f"assets/books/library/works/{mutable_work.get('id')}.json"
            text = _fetch_text(source_text_url) if source_text_url else _fetch_pdf_text(source_pdf_url)
            chapters = _split_plain_text_into_chapters(text)
            generated_work_payload = {
                "id": mutable_work.get("id", ""),
                "title": mutable_work.get("title", ""),
                "author": mutable_work.get("author", ""),
                "language": mutable_work.get("language", "pt-br"),
                "type": mutable_work.get("type", "chapters"),
                "chapters": chapters,
            }
            _write_json(
                output_dir / "works" / f"{mutable_work.get('id')}.json",
                generated_work_payload,
            )
            generated_works[str(mutable_work.get("id"))] = generated_work_payload
            mutable_work["assetPath"] = generated_path
            mutable_work["chapters"] = [
                {
                    "slug": chapter["slug"],
                    "title": chapter["title"],
                    "kind": chapter.get("kind", "chapter"),
                }
                for chapter in chapters
            ]

        author_id = work.get("author_id", "")
        works_by_author.setdefault(author_id, []).append(mutable_work)

    index_authors: list[dict[str, Any]] = []
    for author in authors:
        author_id = author.get("id", "")
        books = sorted(
            works_by_author.get(author_id, []),
            key=lambda item: item.get("title", ""),
        )

        author_asset = f"assets/books/library/authors/{author_id}.json"
        index_authors.append(
            {
                "id": author_id,
                "name": author.get("name", ""),
                "description": author.get("description", ""),
                "language": author.get("language", "pt-br"),
                "worksCount": len(books),
                "assetPath": author_asset,
                "sourceRank": author.get("source_rank", "B"),
            }
        )

        _write_json(
            output_dir / "authors" / f"{author_id}.json",
            {
                "id": author_id,
                "name": author.get("name", ""),
                "books": books,
            },
        )

    _write_json(
        output_dir / "index.json",
        {
            "version": 1,
            "authors": index_authors,
            "generatedWorks": sorted(generated_works.keys()),
        },
    )
