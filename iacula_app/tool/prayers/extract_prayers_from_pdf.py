#!/usr/bin/env python3
"""Extract raw text from prayers PDF for manual/automated normalization."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def extract_with_pypdf(pdf_path: Path) -> list[dict[str, object]]:
    try:
        from pypdf import PdfReader  # type: ignore
    except ImportError as exc:  # pragma: no cover
        raise SystemExit(
            "Missing dependency 'pypdf'. Install with: python3 -m pip install pypdf"
        ) from exc

    reader = PdfReader(str(pdf_path))
    pages: list[dict[str, object]] = []
    for index, page in enumerate(reader.pages, start=1):
        pages.append(
            {
                "page": index,
                "text": (page.extract_text() or "").strip(),
            }
        )
    return pages


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--pdf",
        default="/Users/gabrielttav/Downloads/oracoes.pdf",
        help="Path to canonical prayers PDF",
    )
    parser.add_argument(
        "--out",
        default="tool/prayers/oracoes_extracted.json",
        help="Output JSON path",
    )
    args = parser.parse_args()

    pdf_path = Path(args.pdf)
    if not pdf_path.exists():
        raise SystemExit(f"PDF not found: {pdf_path}")

    pages = extract_with_pypdf(pdf_path)
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(
        json.dumps(
            {
                "source": str(pdf_path),
                "pages": pages,
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"Wrote extracted text to {out_path}")


if __name__ == "__main__":
    main()
