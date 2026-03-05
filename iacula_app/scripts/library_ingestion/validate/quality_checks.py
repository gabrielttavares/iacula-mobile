from __future__ import annotations

import json
import urllib.request
from urllib.parse import urlparse
from typing import Any


VALID_RANKS = {"A", "B", "C"}
ALLOWED_SOURCE_HOST_SUFFIXES = (
    "archive.org",
    "centroculturalcampogrande.pt",
)


def _fetch_archive_metadata(item_id: str) -> dict[str, Any]:
    request = urllib.request.Request(
        f"https://archive.org/metadata/{item_id}",
        headers={"User-Agent": "iacula-library-ingestion/1.0"},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        payload = response.read().decode("utf-8")
    return json.loads(payload).get("metadata", {})


def _to_text(value: Any) -> str:
    if isinstance(value, list):
        return " ".join(str(item) for item in value)
    return str(value or "")


def _validate_archive_identity(work: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    item_id = str(work.get("source_item_id", "")).strip()
    if not item_id:
        return errors

    expected_title = str(work.get("source_expected_title", "")).strip().lower()
    expected_author = str(work.get("source_expected_author", "")).strip().lower()
    try:
        metadata = _fetch_archive_metadata(item_id)
    except Exception as exc:
        return [f"source metadata unavailable for {work.get('id', '<unknown>')}: {exc}"]

    title = _to_text(metadata.get("title")).lower()
    creator = _to_text(metadata.get("creator")).lower()
    language = _to_text(metadata.get("language")).lower()

    if expected_title and expected_title not in title:
        errors.append(f"source title mismatch for {work.get('id', '<unknown>')}")
    if expected_author and expected_author not in creator:
        errors.append(f"source author mismatch for {work.get('id', '<unknown>')}")
    if not any(token in language for token in {"por", "pt", "portugu"}):
        errors.append(f"source language mismatch for {work.get('id', '<unknown>')}: {language}")

    return errors


def validate_work(work: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    if not work.get("id"):
        errors.append("missing work id")
    if not work.get("title"):
        errors.append("missing title")

    language = str(work.get("language", "")).strip().lower()
    if language != "pt-br":
        errors.append(f"work not pt-br: {work.get('id', '<unknown>')} ({language})")

    rank = str(work.get("source_rank", "")).strip().upper()
    if rank not in VALID_RANKS:
        errors.append(f"invalid source rank for {work.get('id', '<unknown>')}: {rank}")

    if work.get("public_domain_verified") is not True:
        errors.append(f"work not public-domain verified: {work.get('id', '<unknown>')}")

    if work.get("available") is True:
        asset_path = str(work.get("assetPath", "")).strip()
        source_text_url = str(work.get("source_text_url", "")).strip()
        source_pdf_url = str(work.get("source_pdf_url", "")).strip()
        if not (asset_path or source_text_url or source_pdf_url):
            errors.append(
                f"available work missing content source: {work.get('id', '<unknown>')}"
            )

    source_item_id = str(work.get("source_item_id", "")).strip()
    source_text_url = str(work.get("source_text_url", "")).strip()
    source_pdf_url = str(work.get("source_pdf_url", "")).strip()

    for source_url in (source_text_url, source_pdf_url):
        if not source_url:
            continue
        host = (urlparse(source_url).hostname or "").lower()
        if not host.endswith(ALLOWED_SOURCE_HOST_SUFFIXES):
            errors.append(
                f"disallowed source host for {work.get('id', '<unknown>')}: {host}"
            )

    uses_archive_source = "archive.org" in source_text_url or "archive.org" in source_pdf_url
    if uses_archive_source and not source_item_id:
        errors.append(
            f"archive source missing source_item_id: {work.get('id', '<unknown>')}"
        )

    errors.extend(_validate_archive_identity(work))

    return errors


def validate_catalog(manifest: dict[str, Any]) -> dict[str, Any]:
    errors: list[str] = []
    works = manifest.get("works", [])
    ids: set[str] = set()

    for work in works:
        work_id = str(work.get("id", ""))
        if work_id in ids:
            errors.append(f"duplicate work id: {work_id}")
        ids.add(work_id)
        errors.extend(validate_work(work))

    return {
        "is_valid": len(errors) == 0,
        "errors": errors,
    }
