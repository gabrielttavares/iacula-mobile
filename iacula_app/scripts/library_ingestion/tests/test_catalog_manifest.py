from __future__ import annotations

import json
import unittest
from pathlib import Path


def _load_manifest() -> dict:
    path = Path("scripts/library_ingestion/catalog_manifest.yaml")
    return json.loads(path.read_text(encoding="utf-8"))


class CatalogManifestTest(unittest.TestCase):
    def test_manifest_contains_only_allowed_authors(self) -> None:
        manifest = _load_manifest()
        self.assertEqual(
            {author["id"] for author in manifest["authors"]},
            {
                "sao-josemaria-escriva",
                "tomas-de-kempis",
                "santo-agostinho",
                "sao-francisco-sales",
                "irmao-lourenco-ressurreicao",
                "santo-afonso-maria-ligorio",
                "jean-pierre-de-caussade",
                "santa-catarina-sena",
                "sao-luis-maria-grignion-de-montfort",
                "francisco-faus",
                "santo-tomas-de-aquino",
            },
        )

    def test_manifest_contains_only_allowed_works(self) -> None:
        manifest = _load_manifest()
        self.assertEqual(
            {work["id"] for work in manifest["works"]},
            {
                "caminho",
                "sulco",
                "forja",
                "e-cristo-que-passa",
                "amigos-de-deus",
                "santo-rosario",
                "via-sacra",
                "em-dialogo-com-o-senhor",
                "imitacao-de-cristo",
                "confissoes",
                "introducao-a-vida-devota",
                "a-pratica-da-presenca-de-deus",
                "tratado-conformidade-vontade-de-deus",
                "a-oracao",
                "preparacao-para-a-morte",
                "a-pratica-do-amor-a-jesus-cristo",
                "o-abandono",
                "o-dialogo",
                "tratado-da-verdadeira-devocao",
                "prudencia",
                "conquista-das-virtudes",
                "credo",
            },
        )

    def test_manifest_has_source_ranking_fields(self) -> None:
        manifest = _load_manifest()
        self.assertTrue(all("source_rank" in source for source in manifest["sources"]))
        self.assertTrue(
            all("public_domain_verified" in work for work in manifest["works"])
        )


if __name__ == "__main__":
    unittest.main()
