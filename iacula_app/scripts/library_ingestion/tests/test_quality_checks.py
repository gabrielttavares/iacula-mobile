from __future__ import annotations

import unittest
from unittest.mock import patch

from scripts.library_ingestion.validate.quality_checks import (
    validate_catalog,
    validate_work,
)


class QualityChecksTest(unittest.TestCase):
    def test_rejects_work_without_public_domain_verification(self) -> None:
        errors = validate_work(
            {
                "id": "x",
                "title": "Test",
                "language": "pt-br",
                "source_rank": "B",
                "public_domain_verified": False,
            }
        )
        self.assertTrue(any("public-domain" in error for error in errors))

    def test_rejects_duplicate_ids(self) -> None:
        validation = validate_catalog(
            {
                "works": [
                    {
                        "id": "same",
                        "title": "A",
                        "language": "pt-br",
                        "source_rank": "A",
                        "public_domain_verified": True,
                    },
                    {
                        "id": "same",
                        "title": "B",
                        "language": "pt-br",
                        "source_rank": "A",
                        "public_domain_verified": True,
                    },
                ]
            }
        )
        self.assertFalse(validation["is_valid"])
        self.assertTrue(any("duplicate" in error for error in validation["errors"]))

    def test_rejects_non_portuguese_work(self) -> None:
        errors = validate_work(
            {
                "id": "eng-book",
                "title": "English title",
                "language": "en",
                "source_rank": "B",
                "public_domain_verified": True,
            }
        )
        self.assertTrue(any("not pt-br" in error for error in errors))

    def test_validates_archive_source_identity(self) -> None:
        with patch(
            "scripts.library_ingestion.validate.quality_checks._fetch_archive_metadata"
        ) as mock_fetch:
            mock_fetch.return_value = {
                "title": "Confissões",
                "creator": "Santo Agostinho",
                "language": "por",
            }

            errors = validate_work(
                {
                    "id": "confissoes",
                    "title": "Confissões",
                    "language": "pt-br",
                    "source_rank": "A",
                    "public_domain_verified": True,
                    "source_item_id": "confissoes-santo-agostinho",
                    "source_expected_title": "confissões",
                    "source_expected_author": "agostinho",
                }
            )

            self.assertEqual(errors, [])

    def test_rejects_available_work_without_asset_or_source(self) -> None:
        errors = validate_work(
            {
                "id": "dangling-work",
                "title": "Dangling",
                "language": "pt-br",
                "source_rank": "A",
                "public_domain_verified": True,
                "available": True,
                "assetPath": "",
                "source_text_url": "",
                "source_pdf_url": "",
            }
        )
        self.assertTrue(any("available work missing content source" in error for error in errors))

    def test_rejects_archive_source_without_identity_fields(self) -> None:
        errors = validate_work(
            {
                "id": "archive-no-identity",
                "title": "Archive Work",
                "language": "pt-br",
                "source_rank": "A",
                "public_domain_verified": True,
                "available": True,
                "source_pdf_url": "https://archive.org/download/example/example.pdf",
            }
        )
        self.assertTrue(any("archive source missing source_item_id" in error for error in errors))

    def test_rejects_disallowed_source_host(self) -> None:
        errors = validate_work(
            {
                "id": "bad-host",
                "title": "Bad Host",
                "language": "pt-br",
                "source_rank": "A",
                "public_domain_verified": True,
                "available": True,
                "source_text_url": "https://example.com/text.txt",
            }
        )
        self.assertTrue(any("disallowed source host" in error for error in errors))

    def test_allows_whitelisted_non_archive_source_host(self) -> None:
        errors = validate_work(
            {
                "id": "allowed-host",
                "title": "Allowed Host",
                "language": "pt-br",
                "source_rank": "C",
                "public_domain_verified": True,
                "available": True,
                "source_pdf_url": "https://www.centroculturalcampogrande.pt/pdfs/a.pratica.da.presenca.de.deus.pdf",
            }
        )
        self.assertEqual(errors, [])

    def test_allows_pocket_terco_html_source(self) -> None:
        errors = validate_work(
            {
                "id": "imitacao-de-cristo",
                "title": "Imitação de Cristo",
                "language": "pt-br",
                "source_rank": "A",
                "public_domain_verified": True,
                "available": True,
                "source_text_url": "https://pocketterco.com.br/livro/imitacao-de-cristo",
            }
        )
        self.assertEqual(errors, [])

    def test_allows_onedrive_share_source(self) -> None:
        errors = validate_work(
            {
                "id": "confissoes",
                "title": "Confissões",
                "language": "pt-br",
                "source_rank": "A",
                "public_domain_verified": True,
                "available": True,
                "source_onedrive_share_url": "https://onedrive.live.com/?authkey=%21abc&id=1&cid=1&o=OneUp",
            }
        )
        self.assertEqual(errors, [])


if __name__ == "__main__":
    unittest.main()
