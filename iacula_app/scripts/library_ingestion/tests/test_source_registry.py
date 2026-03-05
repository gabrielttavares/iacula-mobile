from __future__ import annotations

import unittest

from scripts.library_ingestion.crawl_library import build_source_registry


class SourceRegistryTest(unittest.TestCase):
    def test_source_registry_contains_expected_connectors(self) -> None:
        registry = build_source_registry()
        self.assertIn("escriva_api", registry)
        self.assertIn("wikisource", registry)
        self.assertIn("gutenberg", registry)
        self.assertIn("alexandria_discovery", registry)


if __name__ == "__main__":
    unittest.main()
