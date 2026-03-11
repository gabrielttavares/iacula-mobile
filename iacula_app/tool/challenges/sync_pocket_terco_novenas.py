#!/usr/bin/env python3
"""Sync novena challenge content from multiple external sources."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import tempfile
import unicodedata
import uuid
from html import unescape
from pathlib import Path
from typing import Any, Callable
from urllib.request import Request, urlopen


TOOL_DIR = Path(__file__).resolve().parent
MANIFEST_PATH = TOOL_DIR / "pocket_terco_monthly_novenas.json"
CHALLENGES_PATH = TOOL_DIR.parent.parent / "assets/seed/challenges/challenges.json"
PROJECT_ROOT = TOOL_DIR.parent.parent
OUTPUT_DIR = PROJECT_ROOT / "output/playwright"
BROWSER_STATE_PATH = OUTPUT_DIR / "opusdei-state.json"
USER_AGENT = "Mozilla/5.0 (compatible; IaculaImporter/2.0)"

HttpFetcher = Callable[[str], str | bytes]
BrowserFetcher = Callable[[str, Path], str]
PdfTextFetcher = Callable[[bytes], str]

_DAY_WORDS = {
    "primeiro": 1,
    "segundo": 2,
    "terceiro": 3,
    "quarto": 4,
    "quinto": 5,
    "sexto": 6,
    "setimo": 7,
    "sétimo": 7,
    "oitavo": 8,
    "nono": 9,
}

_DAY_HEADING_RE = re.compile(
    r"^\s*(?:(?P<num>\d{1,2})\s*[º°o]?\s*(?:dia|o)?|(?P<word>primeiro|segundo|terceiro|quarto|quinto|sexto|setimo|sétimo|oitavo|nono)\s+dia)\b(?P<suffix>.*)$",
    re.IGNORECASE,
)
_INLINE_DAY_TITLE_RE = re.compile(
    r"^\s*\d{1,2}\s*[º°o]?\s*dia\s*[:\-–]\s*(.+)$",
    re.IGNORECASE,
)
_ROW_RE = re.compile(
    r"<tr[^>]*>\s*<td[^>]*>\s*<h2[^>]*>(?P<heading>.*?)</h2>\s*(?P<body>.*?)</td>\s*</tr>",
    re.IGNORECASE | re.DOTALL,
)
_META_DESCRIPTION_RE = re.compile(
    r'<meta\s+(?:name|property)="(?:description|og:description)"\s+content="(?P<content>.*?)"\s*/?>',
    re.IGNORECASE | re.DOTALL,
)
_P_TAG_RE = re.compile(r"<p[^>]*>(.*?)</p>", re.IGNORECASE | re.DOTALL)
_BLOCKQUOTE_RE = re.compile(
    r"<blockquote[^>]*>(.*?)</blockquote>",
    re.IGNORECASE | re.DOTALL,
)
_H3_H4_BLOCK_RE = re.compile(
    r"<h3[^>]*>(?P<h3>.*?)</h3>\s*(?:<h4[^>]*>(?P<h4>.*?)</h4>)?\s*(?P<body>.*?)(?=(?:<hr[^>]*>\s*)?<h3[^>]*>|$)",
    re.IGNORECASE | re.DOTALL,
)
_ARTICLE_RE = re.compile(
    r'<article class="editor">(.*?)</article>',
    re.IGNORECASE | re.DOTALL,
)
_EPISODE_LINK_RE = re.compile(
    r'<a class="(?:episode__link|episodes-section-episode__link)" href="(?P<href>[^"]+)" title="(?P<title>[^"]+)"',
    re.IGNORECASE,
)
_POST_CONTENT_RE = re.compile(
    r'<div class="post-content container">(.*?)(?:<section class="post-related"|</div>\s*</div>\s*</article>|<div class="newsletter")',
    re.IGNORECASE | re.DOTALL,
)
_TAG_BLOCK_RE = re.compile(
    r"<(?P<tag>h2|h3|h4|p|blockquote)[^>]*>(?P<body>.*?)</(?P=tag)>",
    re.IGNORECASE | re.DOTALL,
)
_BC_DAY_1_RE = re.compile(
    r'<h[23][^>]*id="dia-1"[^>]*>.*?</h[23]>',
    re.IGNORECASE | re.DOTALL,
)


def strip_accents(value: str) -> str:
    normalized = unicodedata.normalize("NFD", value)
    return "".join(ch for ch in normalized if unicodedata.category(ch) != "Mn")


def normalize_whitespace(value: str) -> str:
    return re.sub(r"\s+", " ", value).strip()


def clean_heading(value: str) -> str:
    value = re.sub(r"<.*?>", "", value, flags=re.DOTALL)
    return normalize_whitespace(unescape(value))


def clean_html_text(value: str) -> str:
    value = value.replace("\r", "")
    value = re.sub(r"<br\s*/?>", "\n", value, flags=re.IGNORECASE)
    value = re.sub(r"</p\s*>", "\n\n", value, flags=re.IGNORECASE)
    value = re.sub(r"<p[^>]*>", "", value, flags=re.IGNORECASE)
    value = re.sub(
        r"</?(strong|em|span|div|table|tbody|tr|td|i|svg|path|small|figure|figcaption|article|section|a)[^>]*>",
        "",
        value,
        flags=re.IGNORECASE,
    )
    value = re.sub(r"<.*?>", "", value, flags=re.DOTALL)
    value = unescape(value).replace("\xa0", " ")
    lines = [re.sub(r"[ \t]+", " ", line).strip() for line in value.split("\n")]

    paragraphs: list[str] = []
    buffer: list[str] = []
    for line in lines:
        if not line:
            if buffer:
                paragraphs.append(" ".join(buffer).strip())
                buffer = []
            continue
        buffer.append(line)
    if buffer:
        paragraphs.append(" ".join(buffer).strip())

    return "\n\n".join(paragraph for paragraph in paragraphs if paragraph)


def extract_meta_description(html: str) -> str:
    match = _META_DESCRIPTION_RE.search(html)
    if not match:
        return ""
    return clean_html_text(match.group("content"))


def detect_day_number(heading: str) -> tuple[int | None, str]:
    match = _DAY_HEADING_RE.match(heading)
    if not match:
        return None, heading

    if match.group("num"):
        day_number = int(match.group("num"))
    else:
        day_number = _DAY_WORDS[match.group("word").lower()]

    suffix = match.group("suffix") or ""
    suffix = re.sub(r"^\s*[\.:;\-–—]\s*", "", suffix)
    return day_number, normalize_whitespace(suffix)


def split_inline_day_title(value: str) -> tuple[str, str]:
    allowed_short_words = {"E", "DE", "DA", "DO", "DOS", "DAS"}
    tokens = value.split()
    title_tokens: list[str] = []

    for token in tokens:
        bare = token.strip(" ,;:()'’-")
        if not bare:
            continue
        if bare in allowed_short_words or (len(strip_accents(bare)) >= 2 and bare == bare.upper()):
            title_tokens.append(token)
            continue
        break

    if not title_tokens:
        return "", value

    title = " ".join(title_tokens).strip(" ,;:()'’-")
    remainder = value[len(" ".join(title_tokens)) :].strip()
    return title, remainder


def derive_day_title(heading: str, body_text: str) -> tuple[str, str]:
    day_number, suffix = detect_day_number(heading)
    if day_number is None:
        return heading, body_text

    if suffix:
        return suffix, body_text

    paragraphs = body_text.split("\n\n")
    for index, paragraph in enumerate(paragraphs):
        inline_match = _INLINE_DAY_TITLE_RE.match(strip_accents(paragraph).lower())
        if not inline_match:
            continue
        extracted = paragraph
        body_title = re.sub(
            r"^\s*\d{1,2}\s*[º°o]?\s*dia\s*[:\-–]\s*",
            "",
            extracted,
            flags=re.IGNORECASE,
        ).strip()
        split_title, remainder = split_inline_day_title(body_title)
        if split_title:
            body_title = split_title
            paragraph = remainder
        else:
            paragraph = ""
        remaining_parts = paragraphs[:index] + paragraphs[index + 1 :]
        if paragraph:
            remaining_parts.insert(index, paragraph)
        remaining = "\n\n".join(part for part in remaining_parts if part).strip()
        return body_title or heading, remaining or body_text

    return heading, body_text


def ensure_nine_days(day_entries: list[dict[str, Any]]) -> dict[str, Any] | None:
    day_entries.sort(key=lambda entry: entry["dayNumber"])
    if [entry["dayNumber"] for entry in day_entries] != list(range(1, 10)):
        return None
    return {"days": day_entries}


def parse_pocket_terco_html(html: str) -> dict[str, Any] | None:
    rows = []
    for match in _ROW_RE.finditer(html):
        heading = clean_heading(match.group("heading"))
        body_text = clean_html_text(match.group("body"))
        if heading and body_text:
            rows.append({"heading": heading, "body": body_text})

    description_parts: list[str] = []
    day_entries: list[dict[str, Any]] = []

    for row in rows:
        day_number, _ = detect_day_number(row["heading"])
        if day_number is None:
            if not day_entries:
                description_parts.append(row["body"])
            continue

        title, reading_text = derive_day_title(row["heading"], row["body"])
        day_entries.append(
            {
                "dayNumber": day_number,
                "title": title,
                "readingText": reading_text,
            }
        )

    validated = ensure_nine_days(day_entries)
    if validated is None:
        return None

    description = "\n\n".join(part for part in description_parts if part).strip()
    if not description:
        description = extract_meta_description(html)

    return {
        "description": description,
        "days": validated["days"],
    }


def _extract_first_group(pattern: re.Pattern[str], html: str) -> str:
    match = pattern.search(html)
    return match.group(1) if match else html


def parse_padre_paulo_richardo_html(html: str) -> dict[str, Any] | None:
    content = _extract_first_group(_POST_CONTENT_RE, html)
    description_parts = [clean_html_text(match.group(1)) for match in _P_TAG_RE.finditer(content)]
    quote_parts = [clean_html_text(match.group(1)) for match in _BLOCKQUOTE_RE.finditer(content)]
    intro_parts = []
    if description_parts:
        intro_parts.append(description_parts[0])
    if quote_parts:
        intro_parts.append(quote_parts[0])

    day_entries = []
    for match in _H3_H4_BLOCK_RE.finditer(content):
        heading = clean_heading(match.group("h3"))
        day_number, _ = detect_day_number(heading)
        if day_number is None:
            continue
        subheading = clean_heading(match.group("h4") or "")
        body_text = clean_html_text(match.group("body"))
        title = subheading or heading
        day_entries.append(
            {
                "dayNumber": day_number,
                "title": title,
                "readingText": body_text,
            }
        )

    validated = ensure_nine_days(day_entries)
    if validated is None:
        return None

    return {
        "description": "\n\n".join(part for part in intro_parts if part).strip()
        or extract_meta_description(html),
        "days": validated["days"],
    }


def parse_padre_paulo_ricardo_program_html(
    html: str,
    http_fetcher: HttpFetcher,
) -> dict[str, Any] | None:
    links = [
        (href if href.startswith("http") else f"https://padrepauloricardo.org{href}", clean_heading(title))
        for href, title in _EPISODE_LINK_RE.findall(html)
    ]
    if len(links) < 9:
        return None

    day_entries = []
    for index, (url, title) in enumerate(links[:9], start=1):
        episode_html = http_fetcher(url)
        match = _ARTICLE_RE.search(episode_html)
        if not match:
            return None
        body_text = clean_html_text(match.group(1))
        day_entries.append(
            {
                "dayNumber": index,
                "title": title,
                "readingText": body_text,
            }
        )

    validated = ensure_nine_days(day_entries)
    if validated is None:
        return None

    return {
        "description": extract_meta_description(html),
        "days": validated["days"],
    }


def parse_biblioteca_catolica_html(html: str) -> dict[str, Any] | None:
    day_one_match = _BC_DAY_1_RE.search(html)
    if not day_one_match:
        return None

    start = max(0, day_one_match.start() - 12000)
    content = html[start:]
    blocks = [
        {"tag": match.group("tag").lower(), "text": clean_html_text(match.group("body"))}
        for match in _TAG_BLOCK_RE.finditer(content)
    ]

    description_parts: list[str] = []
    day_entries: list[dict[str, Any]] = []
    current_day: dict[str, Any] | None = None
    seen_day_numbers: set[int] = set()

    for block in blocks:
        text = block["text"]
        if not text:
            continue

        if block["tag"] in {"h2", "h3", "h4"}:
            day_number, _ = detect_day_number(text)
            if day_number is not None:
                if day_number in seen_day_numbers:
                    break
                if current_day is not None:
                    day_entries.append(current_day)
                    seen_day_numbers.add(current_day["dayNumber"])
                current_day = {
                    "dayNumber": day_number,
                    "title": text,
                    "parts": [],
                }
                continue

        if current_day is None:
            description_parts.append(text)
        else:
            current_day["parts"].append(text)

    if current_day is not None:
        day_entries.append(current_day)
        seen_day_numbers.add(current_day["dayNumber"])

    normalized_days = []
    for day in day_entries:
        normalized_days.append(
            {
                "dayNumber": day["dayNumber"],
                "title": day["title"],
                "readingText": "\n\n".join(part for part in day["parts"] if part).strip(),
            }
        )

    validated = ensure_nine_days(normalized_days)
    if validated is None:
        return None

    return {
        "description": "\n\n".join(description_parts).strip() or extract_meta_description(html),
        "days": validated["days"],
    }


def parse_opusdei_html(html: str) -> dict[str, Any] | None:
    return parse_biblioteca_catolica_html(html)


def _clean_pdf_line(value: str) -> str:
    value = value.replace("\u00a0", " ").replace("", " ").replace("", " ")
    return normalize_whitespace(value)


def _is_pdf_noise_line(value: str) -> bool:
    lowered = strip_accents(value).lower()
    if not lowered:
        return True
    if re.fullmatch(r"\d+", value):
        return True
    if re.fullmatch(r"[-–—]+\d+[-–—]+", value):
        return True
    if re.fullmatch(r"[*_•.]+", value):
        return True
    if lowered in {"indice", "oração a sao josemaria", "oracao a sao josemaria", "***"}:
        return True
    if lowered.startswith(("autor:", "autorizacao", "autorização", "imprimatur", "pede-se", "os livretos")):
        return True
    if lowered.startswith(("www.", "http://", "https://", "para informacoes", "para informações")):
        return True
    if "ecs.br@opusdei.org" in lowered:
        return True
    return False


def _normalize_pdf_lines(text: str) -> list[str]:
    normalized = text.replace("\r", "").replace("\f", "\n\n")
    lines: list[str] = []
    for raw_line in normalized.splitlines():
        line = _clean_pdf_line(raw_line)
        if _is_pdf_noise_line(line):
            lines.append("")
            continue
        lines.append(line)
    return lines


def _is_pdf_section_label(value: str) -> bool:
    lowered = strip_accents(value).lower()
    return lowered in {
        "apresentacao",
        "introducao",
        "instrucoes para fazer a novena",
        "como fazer a novena",
        "reflexao",
        "reflexao: palavras de sao josemaria escriva",
        "meditar com sao josemaria",
        "pedido",
        "oracao",
    }


def _consume_pdf_paragraphs(lines: list[str], start_index: int, stop_at_day: bool = False) -> tuple[list[str], int]:
    paragraphs: list[str] = []
    current_lines: list[str] = []
    index = start_index

    while index < len(lines):
        line = lines[index]
        if stop_at_day and line:
            day_number, _ = detect_day_number(line)
            if day_number is not None:
                break
        if not line:
            if current_lines:
                paragraphs.append(" ".join(current_lines).strip())
                current_lines = []
            index += 1
            continue
        if current_lines and _is_pdf_section_label(current_lines[0]):
            paragraphs.append(" ".join(current_lines).strip())
            current_lines = []
        if _is_pdf_section_label(line):
            if current_lines:
                paragraphs.append(" ".join(current_lines).strip())
                current_lines = []
            paragraphs.append(line)
            index += 1
            continue
        current_lines.append(line)
        index += 1

    if current_lines:
        paragraphs.append(" ".join(current_lines).strip())
    return [paragraph for paragraph in paragraphs if paragraph], index


def parse_opusdei_pdf_text(text: str) -> dict[str, Any] | None:
    lines = _normalize_pdf_lines(text)

    first_day_index: int | None = None
    for index, line in enumerate(lines):
        day_number, _ = detect_day_number(line)
        if day_number == 1:
            first_day_index = index
            break
    if first_day_index is None:
        return None

    description_parts, _ = _consume_pdf_paragraphs(lines, 0, stop_at_day=True)
    description = "\n\n".join(
        part
        for part in description_parts
        if not strip_accents(part).lower().startswith(("novena ", "a sao josemaria", "pe. "))
    ).strip()

    day_entries: list[dict[str, Any]] = []
    index = first_day_index
    while index < len(lines):
        line = lines[index]
        if not line:
            index += 1
            continue

        day_number, inline_title = detect_day_number(line)
        if day_number is None:
            index += 1
            continue

        index += 1
        title = inline_title
        if not title:
            while index < len(lines) and not lines[index]:
                index += 1
            if index < len(lines):
                next_day_number, _ = detect_day_number(lines[index])
                if next_day_number is None:
                    title = lines[index]
                    index += 1

        body_parts, index = _consume_pdf_paragraphs(lines, index, stop_at_day=True)
        day_entries.append(
            {
                "dayNumber": day_number,
                "title": title or line,
                "readingText": "\n\n".join(body_parts).strip(),
            }
        )

    validated = ensure_nine_days(day_entries)
    if validated is None:
        return None

    return {
        "description": description,
        "days": validated["days"],
    }


def parse_source_html(
    source: str,
    html: str,
    http_fetcher: HttpFetcher | None = None,
) -> dict[str, Any] | None:
    if source == "pocket_terco":
        return parse_pocket_terco_html(html)
    if source == "padre_paulo_ricardo_article":
        return parse_padre_paulo_richardo_html(html)
    if source == "padre_paulo_ricardo_program":
        if http_fetcher is None:
            raise ValueError("http_fetcher is required for padre_paulo_ricardo_program")
        return parse_padre_paulo_ricardo_program_html(html, http_fetcher=http_fetcher)
    if source == "biblioteca_catolica":
        return parse_biblioteca_catolica_html(html)
    if source == "opusdei":
        return parse_opusdei_html(html)
    if source == "opusdei_pdf":
        return parse_opusdei_pdf_text(html)
    raise ValueError(f"Unsupported source: {source}")


parse_novena_html = parse_pocket_terco_html


def build_reflection_prompt(title: str) -> str:
    prompt_title = strip_accents(title).lower()
    return f"Que graca desejo pedir por intercessao nesta {prompt_title}?"


def build_challenge_entry(
    challenge_id: str,
    title: str,
    category: str,
    parsed: dict[str, Any],
) -> dict[str, Any]:
    prompt = build_reflection_prompt(title)
    return {
        "id": challenge_id,
        "title": title,
        "description": parsed["description"],
        "durationDays": 9,
        "category": category,
        "content": [
            {
                "dayNumber": day["dayNumber"],
                "title": day["title"],
                "readingText": day["readingText"],
                "reflectionPrompt": prompt,
            }
            for day in parsed["days"]
        ],
    }


def fetch_html(url: str) -> str | bytes:
    request = Request(url, headers={"User-Agent": USER_AGENT})
    with urlopen(request, timeout=30) as response:
        body = response.read()
        if response.headers.get_content_type() == "application/pdf":
            return body
        return body.decode("utf-8", "ignore")


def extract_pdf_text(pdf_content: bytes) -> str:
    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)
        pdf_path = tmp_path / "novena.pdf"
        text_path = tmp_path / "novena.txt"
        pdf_path.write_bytes(pdf_content)
        subprocess.run(
            ["pdftotext", str(pdf_path), str(text_path)],
            check=True,
            capture_output=True,
            text=True,
        )
        return text_path.read_text(encoding="utf-8", errors="ignore")


def default_pwcli_path() -> str:
    codex_home = os.environ.get("CODEX_HOME", str(Path.home() / ".codex"))
    return str(Path(codex_home) / "skills/playwright/scripts/playwright_cli.sh")


def run_pwcli(session: str, *args: str, capture_output: bool = True) -> subprocess.CompletedProcess[str]:
    command = [default_pwcli_path(), f"-s={session}", *args]
    return subprocess.run(
        command,
        cwd=PROJECT_ROOT,
        check=True,
        text=True,
        capture_output=capture_output,
    )


def fetch_html_with_playwright_state(url: str, state_path: Path) -> str:
    session = f"opusdei-{uuid.uuid4().hex[:8]}"
    run_pwcli(session, "open", "about:blank")
    try:
        run_pwcli(session, "state-load", str(state_path))
        run_pwcli(session, "goto", url)
        result = run_pwcli(
            session,
            "eval",
            "() => document.documentElement.outerHTML",
        )
        lines = [line for line in result.stdout.splitlines() if line.strip()]
        return lines[-1] if lines else ""
    finally:
        subprocess.run(
            [default_pwcli_path(), f"-s={session}", "close"],
            cwd=PROJECT_ROOT,
            text=True,
            capture_output=True,
            check=False,
        )


def fetch_item_html(
    item: dict[str, Any],
    http_fetcher: HttpFetcher = fetch_html,
    browser_fetcher: BrowserFetcher = fetch_html_with_playwright_state,
    pdf_text_fetcher: PdfTextFetcher = extract_pdf_text,
    state_path: Path = BROWSER_STATE_PATH,
) -> str:
    access_mode = item.get("access_mode", "http")
    url = item["url"]
    if access_mode == "http":
        content = http_fetcher(url)
        if item.get("source") == "opusdei_pdf":
            if isinstance(content, str):
                content = content.encode("utf-8")
            extracted_text = pdf_text_fetcher(content)
            if not extracted_text.strip():
                raise ValueError(f"PDF extraction returned no text for {url}")
            return extracted_text
        if isinstance(content, bytes):
            return content.decode("utf-8", "ignore")
        return content
    if access_mode == "browser_state":
        if not state_path.exists():
            raise FileNotFoundError(f"Browser state not found: {state_path}")
        return browser_fetcher(url, state_path)
    raise ValueError(f"Unsupported access mode: {access_mode}")


def load_manifest(path: Path = MANIFEST_PATH) -> list[dict[str, Any]]:
    return json.loads(path.read_text(encoding="utf-8"))


def merge_challenges(
    existing: list[dict[str, Any]],
    imported: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    imported_by_id = {entry["id"]: entry for entry in imported}
    merged = []
    for entry in existing:
        merged.append(imported_by_id.pop(entry["id"], entry))
    merged.extend(imported_by_id.values())
    return merged


def sync_novenas(
    manifest_path: Path = MANIFEST_PATH,
    challenges_path: Path = CHALLENGES_PATH,
    dry_run: bool = False,
    state_path: Path = BROWSER_STATE_PATH,
) -> tuple[list[dict[str, Any]], list[str], list[str]]:
    manifest = load_manifest(manifest_path)
    existing = json.loads(challenges_path.read_text(encoding="utf-8"))
    imported_entries = []
    imported_titles = []
    skipped = []

    for item in manifest:
        try:
            html = fetch_item_html(item, state_path=state_path)
        except FileNotFoundError:
            skipped.append(f"{item['title']} (missing browser state)")
            continue

        parsed = parse_source_html(item["source"], html, http_fetcher=fetch_html)
        if parsed is None:
            skipped.append(f"{item['title']} (parse failed)")
            continue

        imported_entries.append(
            build_challenge_entry(
                challenge_id=item["id"],
                title=item["title"],
                category="novena",
                parsed=parsed,
            )
        )
        imported_titles.append(item["title"])

    merged = merge_challenges(existing, imported_entries)
    if not dry_run:
        challenges_path.write_text(
            json.dumps(merged, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    return merged, imported_titles, skipped


sync_monthly_novenas = sync_novenas


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--state-path", default=str(BROWSER_STATE_PATH))
    args = parser.parse_args()

    merged, imported_titles, skipped = sync_novenas(
        dry_run=args.dry_run,
        state_path=Path(args.state_path),
    )
    print(f"Imported {len(imported_titles)} novenas")
    for title in imported_titles:
        print(f"- {title}")
    if skipped:
        print("Skipped:")
        for item in skipped:
            print(f"- {item}")
    print(f"Challenge entries after merge: {len(merged)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
