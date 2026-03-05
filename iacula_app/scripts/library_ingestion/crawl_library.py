#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any


SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent

if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from scripts.library_ingestion.export.export_json import export_catalog_assets  # noqa: E402
from scripts.library_ingestion.normalize.normalize_content import normalize_catalog  # noqa: E402
from scripts.library_ingestion.validate.quality_checks import validate_catalog  # noqa: E402
from scripts.library_ingestion.sources.alexandria_source import AlexandriaSource  # noqa: E402
from scripts.library_ingestion.sources.escriva_source import EscrivaSource  # noqa: E402
from scripts.library_ingestion.sources.gutenberg_source import GutenbergSource  # noqa: E402
from scripts.library_ingestion.sources.wikisource_source import WikisourceSource  # noqa: E402


def build_source_registry() -> dict[str, object]:
    return {
        "escriva_api": EscrivaSource(),
        "wikisource": WikisourceSource(),
        "gutenberg": GutenbergSource(),
        "alexandria_discovery": AlexandriaSource(),
    }


def _load_manifest() -> dict[str, Any]:
    manifest_path = SCRIPT_DIR / "catalog_manifest.yaml"
    raw = manifest_path.read_text(encoding="utf-8")
    try:
        import yaml  # type: ignore

        return yaml.safe_load(raw)
    except Exception:
        return json.loads(raw)


def main() -> None:
    manifest = _load_manifest()
    sources = build_source_registry()

    normalized_manifest = normalize_catalog(manifest)
    validation = validate_catalog(normalized_manifest)
    if not validation["is_valid"]:
        reasons = ", ".join(validation["errors"])
        raise SystemExit(f"Catalog validation failed: {reasons}")

    output_dir = PROJECT_ROOT / "assets" / "books" / "library"
    export_catalog_assets(
        manifest=normalized_manifest,
        source_registry=sources,
        output_dir=output_dir,
    )

    reports_dir = SCRIPT_DIR / "reports"
    reports_dir.mkdir(parents=True, exist_ok=True)
    report = {
        "is_valid": validation["is_valid"],
        "errors": validation["errors"],
        "authors": len(normalized_manifest.get("authors", [])),
        "works": len(normalized_manifest.get("works", [])),
    }
    (reports_dir / "ingestion_report.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    works = normalized_manifest.get("works", [])
    print(f"Generated library catalog with {len(works)} works in {output_dir}")


if __name__ == "__main__":
    main()
