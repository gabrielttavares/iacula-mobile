#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent

if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

from export_json import export_books  # noqa: E402
from extract_book import extract_books  # noqa: E402
from normalize_content import normalize_books  # noqa: E402


def main() -> None:
    extracted = extract_books()
    normalized = normalize_books(extracted)

    output_dir = PROJECT_ROOT / "assets" / "books" / "escriva"
    export_books(normalized, output_dir)

    print(f"Generated {len(normalized)} books in {output_dir}")


if __name__ == "__main__":
    main()
