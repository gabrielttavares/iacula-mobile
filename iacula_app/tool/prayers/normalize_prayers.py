#!/usr/bin/env python3
"""Normalize prayers catalog and generate per-slug detail files."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


LANG_PT = "pt-br"
LANG_LA = "la"

# Bidirectional prayer pairs for PT/LAT detail synthesis.
PAIR_MAP = {
    "anjo-do-senhor": "angelus",
    "angelus": "anjo-do-senhor",
    "rainha-do-ceu": "regina-coeli",
    "regina-coeli": "rainha-do-ceu",
    "lembrai-vos": "memorare",
    "memorare": "lembrai-vos",
    "rosario-portugues": "rosario-latim",
    "rosario-latim": "rosario-portugues",
    "responso-portugues": "responso-latim",
    "responso-latim": "responso-portugues",
}


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def infer_language(entry: dict[str, object]) -> str:
    slug = str(entry.get("id", "")).lower()
    title = str(entry.get("title", "")).lower()
    if "latim" in title or "latin" in title or slug.endswith("-latim"):
        return LANG_LA
    if slug in {"angelus", "regina-coeli", "memorare", "ubi-caritas", "responso-latim"}:
        return LANG_LA
    return LANG_PT


def choose_section(
    entry: dict[str, object],
    mapping: dict[str, dict[str, str]],
) -> tuple[str, str]:
    themes = entry.get("theme", [])
    if isinstance(themes, list):
        for theme in themes:
            resolved = mapping.get(str(theme))
            if resolved:
                return resolved["section_id"], resolved["section_title"]
    return "diversos", "Orações Diversas"


def build_detail(
    entry: dict[str, object],
    by_id: dict[str, dict[str, object]],
) -> tuple[dict[str, object], list[str]]:
    slug = str(entry["id"])
    title = str(entry.get("title", slug))
    content = str(entry.get("content", "")).strip()
    language = infer_language(entry)

    titles: dict[str, str] = {language: title}
    blocks: dict[str, list[str]] = {language: [content] if content else []}

    paired_id = PAIR_MAP.get(slug)
    if paired_id and paired_id in by_id:
        paired = by_id[paired_id]
        paired_lang = infer_language(paired)
        paired_title = str(paired.get("title", paired_id))
        paired_content = str(paired.get("content", "")).strip()
        titles[paired_lang] = paired_title
        blocks[paired_lang] = [paired_content] if paired_content else []

    available = sorted([lang for lang, parts in blocks.items() if parts])
    detail = {
        "slug": slug,
        "default_language": LANG_PT if LANG_PT in available else available[0],
        "titles": {k: v for k, v in titles.items() if v},
        "blocks": {k: v for k, v in blocks.items() if v},
    }
    return detail, available


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--catalog",
        default="assets/seed/prayers/pt-br/oracoes_catalog.json",
        help="Input catalog path",
    )
    parser.add_argument(
        "--mapping",
        default="tool/prayers/section_mapping.json",
        help="Section mapping JSON path",
    )
    parser.add_argument(
        "--details-dir",
        default="assets/seed/prayers/details",
        help="Output detail directory",
    )
    args = parser.parse_args()

    catalog_path = Path(args.catalog)
    mapping_path = Path(args.mapping)
    details_dir = Path(args.details_dir)

    catalog: list[dict[str, object]] = load_json(catalog_path)
    mapping: dict[str, dict[str, str]] = load_json(mapping_path)
    by_id = {
        str(entry.get("id", "")): entry
        for entry in catalog
        if isinstance(entry, dict) and entry.get("id")
    }

    details_dir.mkdir(parents=True, exist_ok=True)

    normalized_catalog: list[dict[str, object]] = []
    for entry in catalog:
        if not isinstance(entry, dict):
            continue
        if not entry.get("id") or not entry.get("title"):
            continue

        detail, available = build_detail(entry, by_id)
        slug = str(entry["id"])
        (details_dir / f"{slug}.json").write_text(
            json.dumps(detail, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

        section_id, section_title = choose_section(entry, mapping)
        normalized = {
            "id": slug,
            "title": entry.get("title", ""),
            "content": entry.get("content", ""),
            "section_id": section_id,
            "section_title": section_title,
            "languages": available if available else [infer_language(entry)],
            "theme": entry.get("theme", []),
            "saints": entry.get("saints", []),
        }
        normalized_catalog.append(normalized)

    catalog_path.write_text(
        json.dumps(normalized_catalog, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Updated catalog: {catalog_path}")
    print(f"Generated details: {details_dir}")


if __name__ == "__main__":
    main()
