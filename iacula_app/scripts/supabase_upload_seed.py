#!/usr/bin/env python3
import argparse
import json
import mimetypes
import os
import shutil
import sys
import tempfile
from pathlib import Path
from typing import Dict, List, Tuple
from urllib import error, parse, request

try:
    from PIL import Image
    PIL_AVAILABLE = True
except Exception:
    PIL_AVAILABLE = False


BUCKET_IMAGES = "iacula_images"
BUCKET_AUDIOS = "iacula_audios"
BUCKET_TEXTS = "iacula_texts"


def _http_json(method: str, url: str, token: str, payload: dict | None = None) -> tuple[int, str]:
    data = None
    headers = {
        "Authorization": f"Bearer {token}",
        "apikey": token,
    }
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = request.Request(url=url, data=data, method=method, headers=headers)
    try:
        with request.urlopen(req, timeout=120) as resp:
            body = resp.read().decode("utf-8", errors="replace")
            return resp.status, body
    except error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        return e.code, body


def _http_upload(url: str, token: str, content: bytes, content_type: str, upsert: bool = True) -> tuple[int, str]:
    headers = {
        "Authorization": f"Bearer {token}",
        "apikey": token,
        "Content-Type": content_type,
        "x-upsert": "true" if upsert else "false",
    }
    req = request.Request(url=url, data=content, method="POST", headers=headers)
    try:
        with request.urlopen(req, timeout=300) as resp:
            body = resp.read().decode("utf-8", errors="replace")
            return resp.status, body
    except error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        return e.code, body


def ensure_bucket(project_url: str, token: str, bucket_id: str, public: bool = True) -> None:
    list_url = f"{project_url}/storage/v1/bucket"
    code, body = _http_json("GET", list_url, token)
    if code >= 300:
        raise RuntimeError(f"Failed to list buckets: HTTP {code} {body}")

    try:
        buckets = json.loads(body)
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"Invalid bucket list response: {exc}") from exc

    if any((b.get("id") == bucket_id for b in buckets if isinstance(b, dict))):
        return

    create_payload = {
        "id": bucket_id,
        "name": bucket_id,
        "public": public,
    }
    ccode, cbody = _http_json("POST", list_url, token, create_payload)
    if ccode >= 300:
        raise RuntimeError(f"Failed to create bucket '{bucket_id}': HTTP {ccode} {cbody}")


def map_bucket_and_key(seed_root: Path, file_path: Path) -> Tuple[str, str]:
    rel = file_path.relative_to(seed_root).as_posix()
    if rel.startswith("images/"):
        return BUCKET_IMAGES, rel[len("images/"):]
    if rel.startswith("audio/"):
        return BUCKET_AUDIOS, rel[len("audio/"):]
    return BUCKET_TEXTS, rel


def maybe_compress_image(src: Path, quality: int, temp_dir: Path) -> Tuple[bytes, bool]:
    raw = src.read_bytes()
    if not PIL_AVAILABLE:
        return raw, False

    ext = src.suffix.lower()
    if ext not in {".jpg", ".jpeg", ".png"}:
        return raw, False

    out_path = temp_dir / src.name
    try:
        with Image.open(src) as img:
            if ext in {".jpg", ".jpeg"}:
                rgb_img = img.convert("RGB")
                rgb_img.save(out_path, format="JPEG", quality=quality, optimize=True, progressive=True)
            else:
                img.save(out_path, format="PNG", optimize=True)
        out = out_path.read_bytes()
    except Exception:
        return raw, False

    if len(out) >= len(raw):
        return raw, False
    return out, True


def iter_seed_files(seed_root: Path) -> List[Path]:
    files: List[Path] = []
    for p in seed_root.rglob("*"):
        if p.is_file() and p.name != ".gitkeep":
            files.append(p)
    files.sort()
    return files


def upload_seed_assets(project_url: str, token: str, seed_root: Path, quality: int, dry_run: bool) -> None:
    ensure_bucket(project_url, token, BUCKET_IMAGES, public=True)
    ensure_bucket(project_url, token, BUCKET_AUDIOS, public=True)
    ensure_bucket(project_url, token, BUCKET_TEXTS, public=True)

    files = iter_seed_files(seed_root)
    if not files:
        print("No files found under assets/seed.")
        return

    uploaded = 0
    compressed = 0
    bytes_in = 0
    bytes_out = 0
    failures: List[str] = []

    with tempfile.TemporaryDirectory(prefix="iacula_seed_upload_") as tmp:
        temp_dir = Path(tmp)

        for file_path in files:
            bucket, object_key = map_bucket_and_key(seed_root, file_path)
            content_type = mimetypes.guess_type(file_path.name)[0] or "application/octet-stream"

            if file_path.suffix.lower() in {".jpg", ".jpeg", ".png"}:
                payload, was_compressed = maybe_compress_image(file_path, quality=quality, temp_dir=temp_dir)
                if was_compressed:
                    compressed += 1
            else:
                payload = file_path.read_bytes()

            bytes_in += file_path.stat().st_size
            bytes_out += len(payload)

            encoded_key = parse.quote(object_key, safe="/-_.~")
            url = f"{project_url}/storage/v1/object/{bucket}/{encoded_key}"

            if dry_run:
                print(f"DRY-RUN {bucket}/{object_key} ({len(payload)} bytes)")
                uploaded += 1
                continue

            code, body = _http_upload(url, token, payload, content_type, upsert=True)
            if code >= 300:
                failures.append(f"{bucket}/{object_key}: HTTP {code} {body}")
                continue
            uploaded += 1
            print(f"UPLOADED {bucket}/{object_key} ({len(payload)} bytes)")

    print("\nSummary")
    print(f"- files processed: {len(files)}")
    print(f"- files uploaded: {uploaded}")
    print(f"- images compressed: {compressed}")
    print(f"- original bytes: {bytes_in}")
    print(f"- uploaded bytes: {bytes_out}")
    if failures:
        print(f"- failures: {len(failures)}")
        for item in failures:
            print(f"  {item}")
        raise SystemExit(1)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Compress and upload assets/seed to Supabase Storage.")
    parser.add_argument("--project-url", required=True, help="Supabase project URL, e.g. https://<ref>.supabase.co")
    parser.add_argument("--service-role-key", required=True, help="Supabase service role key")
    parser.add_argument("--seed-root", default="assets/seed", help="Path to assets/seed")
    parser.add_argument("--jpeg-quality", type=int, default=92, help="JPEG compression quality (1-100)")
    parser.add_argument("--dry-run", action="store_true", help="Do not upload, only print actions")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    seed_root = Path(args.seed_root).resolve()
    if not seed_root.exists():
        raise SystemExit(f"Seed root not found: {seed_root}")

    if not (1 <= args.jpeg_quality <= 100):
        raise SystemExit("--jpeg-quality must be between 1 and 100")

    upload_seed_assets(
        project_url=args.project_url.rstrip("/"),
        token=args.service_role_key,
        seed_root=seed_root,
        quality=args.jpeg_quality,
        dry_run=args.dry_run,
    )


if __name__ == "__main__":
    main()
