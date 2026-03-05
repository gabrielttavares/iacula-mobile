from __future__ import annotations

import json
import unittest
from pathlib import Path


def _load_manifest() -> dict:
    path = Path("scripts/library_ingestion/catalog_manifest.yaml")
    return json.loads(path.read_text(encoding="utf-8"))


class CatalogManifestTest(unittest.TestCase):
    def test_manifest_has_at_least_30_works(self) -> None:
        manifest = _load_manifest()
        self.assertGreaterEqual(len(manifest["works"]), 30)

    def test_manifest_has_source_ranking_fields(self) -> None:
        manifest = _load_manifest()
        self.assertTrue(all("source_rank" in source for source in manifest["sources"]))
        self.assertTrue(
            all("public_domain_verified" in work for work in manifest["works"])
        )


if __name__ == "__main__":
    unittest.main()
