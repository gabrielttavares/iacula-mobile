# Library Ingestion Ops Runbook

## Commands

- Build/update catalog assets:

```bash
python3 scripts/library_ingestion/crawl_library.py
```

- Validate ingestion tests:

```bash
python3 -m unittest discover -s scripts/library_ingestion/tests -p "test_*.py" -v
```

- Validate Flutter consumer flow:

```bash
fvm flutter test test/features/leituras/data/author_catalog_test.dart test/features/leituras/data/leitura_repository_test.dart test/features/leituras/presentation/leituras_navigation_test.dart
```

## Data outputs

- `assets/books/library/index.json`
- `assets/books/library/authors/*.json`
- `scripts/library_ingestion/reports/ingestion_report.json`

## Adding new author/work

1. Add author metadata in `scripts/library_ingestion/catalog_manifest.yaml` under `authors`.
2. Add work entries under `works` with:
   - `source_rank`
   - `public_domain_verified`
   - `language: pt-br`
   - `available`
   - `author_id`
   - if `available: true`, provide either `assetPath` or source URL (`source_text_url` / `source_pdf_url`)
   - for Archive sources, always include:
     - `source_item_id`
     - `source_expected_title`
     - `source_expected_author`
   - only `archive.org` hosts are accepted for content URLs by quality checks
3. Re-run `python3 scripts/library_ingestion/crawl_library.py`.
4. Run unittest + Flutter Leituras tests.

## Candidate discovery (Alexandria Catolica)

- Use `https://alexandriacatolica.blogspot.com/` as a discovery feed for candidate titles in pt-BR.
- Treat Blogspot/Mega/Drive links as leads only; do not ingest from those hosts directly.
- Promote a work to `available: true` only after finding a canonical `archive.org` source that passes metadata identity and language validation.
