from __future__ import annotations

import unittest

from scripts.library_ingestion.sources.alexandria_source import AlexandriaSource


class AlexandriaSourceTest(unittest.TestCase):
    def test_extracts_post_title_and_download_link_candidates(self) -> None:
        markdown = """
### [História de uma Alma ➜ REFORMATADO](https://alexandriacatolica.blogspot.com/2026/01/historia-de-uma-alma.html)

[História de uma Alma](https://mega.nz/file/example)
"""
        source = AlexandriaSource()
        candidates = source.extract_candidates(markdown)

        self.assertEqual(len(candidates), 1)
        self.assertEqual(candidates[0]["title"], "História de uma Alma")
        self.assertEqual(candidates[0]["post_url"], "https://alexandriacatolica.blogspot.com/2026/01/historia-de-uma-alma.html")
        self.assertEqual(candidates[0]["download_urls"], ["https://mega.nz/file/example"])


if __name__ == "__main__":
    unittest.main()
