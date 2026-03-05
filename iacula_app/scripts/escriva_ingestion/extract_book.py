#!/usr/bin/env python3
from __future__ import annotations

import html
import json
import re
import urllib.parse
import urllib.request
from dataclasses import dataclass
from html.parser import HTMLParser
from typing import Any

try:
    from bs4 import BeautifulSoup  # type: ignore
except Exception:  # pragma: no cover - optional dependency fallback
    BeautifulSoup = None

API_BASE = "https://escriva.org/api/v1"
SITE_ID = 6

TARGET_BOOK_IDS = {
    15: "caminho",
    38: "sulco",
    61: "forja",
    103: "e-cristo-que-passa",
    92: "amigos-de-deus",
    505: "em-dialogo-com-o-senhor",
    118: "santo-rosario",
    122: "via-sacra",
}

WEBSITE_BOOK_SLUGS = {
    15: "camino",
    38: "surco",
    61: "forja",
    103: "es-cristo-que-pasa",
    92: "amigos-de-dios",
    505: "en-dialogo-con-el-se%C3%B1or",
}

HOMILY_BOOK_IDS = {103, 92, 505}


@dataclass(frozen=True)
class BookSeed:
    id: int
    slug: str
    title: str
    group: str
    chapter_list_url: str
    point_list_url: str


def _fetch_json(url: str, params: dict[str, Any] | None = None) -> dict[str, Any]:
    final_url = url
    if params:
        encoded = urllib.parse.urlencode(params, doseq=True)
        separator = "&" if "?" in url else "?"
        final_url = f"{url}{separator}{encoded}"

    request = urllib.request.Request(
        final_url,
        headers={"User-Agent": "iacula-escriva-ingestion/1.0"},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        payload = response.read().decode("utf-8")
    return json.loads(payload)


def _paginate_results(url: str, params: dict[str, Any] | None = None) -> list[dict[str, Any]]:
    results: list[dict[str, Any]] = []
    next_url: str | None = url
    first = True

    while next_url:
        payload = _fetch_json(next_url, params if first else None)
        first = False
        page = payload.get("results", [])
        if isinstance(page, list):
            results.extend(page)
        next_url = payload.get("next")

    return results


def _slugify(value: str) -> str:
    cleaned = value.strip().lower()
    cleaned = cleaned.replace("ã", "a").replace("á", "a").replace("à", "a")
    cleaned = cleaned.replace("â", "a").replace("é", "e").replace("ê", "e")
    cleaned = cleaned.replace("í", "i").replace("ó", "o").replace("ô", "o")
    cleaned = cleaned.replace("õ", "o").replace("ú", "u").replace("ç", "c")
    cleaned = re.sub(r"[^a-z0-9\s-]", "", cleaned)
    cleaned = re.sub(r"\s+", "-", cleaned)
    cleaned = re.sub(r"-+", "-", cleaned)
    return cleaned.strip("-")


def _html_to_paragraphs(raw_html: str) -> list[str]:
    if not raw_html:
        return []

    if BeautifulSoup is None:
        parser = _ParagraphParser()
        parser.feed(raw_html)
        return [html.unescape(item) for item in parser.paragraphs if item]

    soup = BeautifulSoup(raw_html, "html.parser")
    paragraphs: list[str] = []
    nodes = soup.find_all(["p", "li"])
    if not nodes:
        text = soup.get_text(" ", strip=True)
        return [html.unescape(text)] if text else []

    for node in nodes:
        text = node.get_text(" ", strip=True)
        if text:
            paragraphs.append(html.unescape(text))
    return paragraphs


class _ParagraphParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self._collecting = False
        self._buffer: list[str] = []
        self.paragraphs: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag in {"p", "li"}:
            self._collecting = True
            self._buffer = []

    def handle_data(self, data: str) -> None:
        if self._collecting:
            self._buffer.append(data)

    def handle_endtag(self, tag: str) -> None:
        if tag in {"p", "li"} and self._collecting:
            text = " ".join(self._buffer)
            text = re.sub(r"\s+", " ", text).strip()
            if text:
                self.paragraphs.append(text)
            self._collecting = False
            self._buffer = []


def _extract_prologue_with_playwright(book_slug: str) -> dict[str, Any] | None:
    url = f"https://escriva.org/pt-br/{book_slug}/intro/prologo-do-autor/"
    content: str | None = None

    try:
        from playwright.sync_api import sync_playwright  # type: ignore

        with sync_playwright() as playwright:
            browser = playwright.chromium.launch(headless=True)
            page = browser.new_page()
            response = page.goto(url, wait_until="networkidle", timeout=30000)
            if response is not None and response.status < 400:
                content = page.content()
            browser.close()
    except Exception:
        content = None

    if content is None:
        try:
            request = urllib.request.Request(
                url,
                headers={"User-Agent": "iacula-escriva-ingestion/1.0"},
            )
            with urllib.request.urlopen(request, timeout=30) as response:
                if response.status >= 400:
                    return None
                content = response.read().decode("utf-8")
        except Exception:
            return None

    if content is None:
        return None

    if BeautifulSoup is None:
        title_match = re.search(r"<h1[^>]*>(.*?)</h1>", content, re.IGNORECASE | re.DOTALL)
        title = "Prólogo do autor"
        if title_match:
            title = _normalize_inline_html(title_match.group(1))

        parser = _ParagraphParser()
        parser.feed(content)
        paragraphs = [
            text
            for text in parser.paragraphs
            if "documento impresso" not in text.lower()
            and "compartilhar" not in text.lower()
            and len(text) > 10
        ]

        if not paragraphs:
            return None

        return {
            "slug": "prologo-do-autor",
            "title": title,
            "kind": "intro",
            "paragraphs": [html.unescape(item) for item in paragraphs],
        }

    soup = BeautifulSoup(content, "html.parser")
    heading = soup.select_one("h1")
    title = heading.get_text(" ", strip=True) if heading else "Prólogo do autor"

    paragraph_candidates = soup.select("#content p, main p")
    paragraphs: list[str] = []
    for paragraph in paragraph_candidates:
        text = paragraph.get_text(" ", strip=True)
        if not text:
            continue
        lowered = text.lower()
        if "documento impresso" in lowered or "compartilhar" in lowered:
            continue
        paragraphs.append(html.unescape(text))

    if not paragraphs:
        return None

    return {
        "slug": "prologo-do-autor",
        "title": title,
        "kind": "intro",
        "paragraphs": paragraphs,
    }


def _normalize_inline_html(raw_value: str) -> str:
    text = re.sub(r"<[^>]+>", " ", raw_value)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def collect_target_books() -> list[BookSeed]:
    books = _paginate_results(f"{API_BASE}/books/", {"site_id": SITE_ID, "limit": 100})
    seeds: list[BookSeed] = []
    for item in books:
        book_id = int(item.get("id", 0))
        if book_id not in TARGET_BOOK_IDS:
            continue

        seeds.append(
            BookSeed(
                id=book_id,
                slug=TARGET_BOOK_IDS[book_id],
                title=item.get("name", "").strip(),
                group=item.get("book_group", "").strip(),
                chapter_list_url=item.get("chapter_list_url", "").strip(),
                point_list_url=item.get("point_list_url", "").strip(),
            )
        )

    order = list(TARGET_BOOK_IDS.keys())
    seeds.sort(key=lambda b: order.index(b.id))
    return seeds


def _extract_base_book(seed: BookSeed) -> dict[str, Any]:
    chapters = _paginate_results(seed.chapter_list_url, {"limit": 100})
    output_chapters: list[dict[str, Any]] = []

    website_slug = WEBSITE_BOOK_SLUGS.get(seed.id)
    prologue = (
        _extract_prologue_with_playwright(website_slug)
        if website_slug is not None
        else None
    )
    if prologue is not None:
        output_chapters.append(prologue)

    for chapter in chapters:
        chapter_id = chapter.get("id")
        chapter_title = chapter.get("name", "").strip()
        chapter_slug = _slugify(chapter_title) or f"chapter-{chapter_id}"

        points = _paginate_results(chapter.get("point_list_url", ""), {"limit": 100})
        sections: list[dict[str, Any]] = []
        for point in points:
            sections.append(
                {
                    "number": point.get("number"),
                    "label": point.get("label"),
                    "paragraphs": _html_to_paragraphs(point.get("text", "")),
                    "source_url": point.get("public_url", ""),
                }
            )

        output_chapters.append(
            {
                "slug": chapter_slug,
                "title": chapter_title,
                "kind": "homily" if seed.id in HOMILY_BOOK_IDS else "points",
                "sections": sections,
                "source_url": chapter.get("url", ""),
            }
        )

    return {
        "id": seed.slug,
        "book_id": seed.id,
        "title": seed.title,
        "author": "São Josemaría Escrivá",
        "group": seed.group,
        "chapters": output_chapters,
    }


def _extract_holy_rosary(seed: BookSeed) -> dict[str, Any]:
    chapters = _paginate_results(seed.chapter_list_url, {"limit": 100})
    output_chapters: list[dict[str, Any]] = []

    for chapter in chapters:
        chapter_title = chapter.get("name", "").strip()
        chapter_slug = _slugify(chapter_title)
        mysteries = _paginate_results(chapter.get("mystery_list_url", ""), {"limit": 100})
        sections = []
        for mystery in mysteries:
            sections.append(
                {
                    "number": mystery.get("number"),
                    "title": mystery.get("name", "").strip(),
                    "paragraphs": _html_to_paragraphs(mystery.get("text", "")),
                    "source_url": mystery.get("public_url", ""),
                }
            )
        output_chapters.append(
            {
                "slug": chapter_slug,
                "title": chapter_title,
                "kind": "mysteries",
                "sections": sections,
                "source_url": chapter.get("url", ""),
            }
        )

    return {
        "id": seed.slug,
        "book_id": seed.id,
        "title": seed.title,
        "author": "São Josemaría Escrivá",
        "group": seed.group,
        "chapters": output_chapters,
    }


def _extract_one_level(seed: BookSeed) -> dict[str, Any]:
    texts = _paginate_results(seed.chapter_list_url, {"limit": 100})
    sections: list[dict[str, Any]] = []
    for index, item in enumerate(texts, start=1):
        section_title = item.get("name", "").strip()
        parsed_number = item.get("number")
        if parsed_number is None:
            parsed_number = index

        sections.append(
            {
                "number": parsed_number,
                "title": section_title,
                "paragraphs": _html_to_paragraphs(item.get("text", "")),
                "source_url": item.get("public_url", ""),
            }
        )

    return {
        "id": seed.slug,
        "book_id": seed.id,
        "title": seed.title,
        "author": "São Josemaría Escrivá",
        "group": seed.group,
        "chapters": [
            {
                "slug": "estacoes",
                "title": "Estações",
                "kind": "stations",
                "sections": sections,
            }
        ],
    }


def extract_books() -> list[dict[str, Any]]:
    books = collect_target_books()
    extracted: list[dict[str, Any]] = []

    for book in books:
        if book.group == "base":
            extracted.append(_extract_base_book(book))
        elif book.group == "holy-rosary":
            extracted.append(_extract_holy_rosary(book))
        elif book.group == "one-level":
            extracted.append(_extract_one_level(book))
        else:
            raise ValueError(f"Unsupported book group: {book.group}")

    return extracted
