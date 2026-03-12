from __future__ import annotations

import unittest
from io import BytesIO
from unittest.mock import patch
from urllib.error import HTTPError

from scripts.library_ingestion.export.export_json import (
    _parse_pocket_terco_html,
    _fetch_url_bytes,
    _split_plain_text_into_chapters,
)


class ExportPlainTextTest(unittest.TestCase):
    def test_splits_chaptered_plain_text(self) -> None:
        text = """
CAPÍTULO I - Primeira Parte

Parágrafo um.

Parágrafo dois.

CAPÍTULO II - Segunda Parte

Parágrafo três.
"""
        chapters = _split_plain_text_into_chapters(text)
        self.assertEqual(len(chapters), 2)
        self.assertEqual(chapters[0]["title"], "Capítulo I - Primeira Parte")

    def test_fetch_url_bytes_retries_once_after_401(self) -> None:
        transient_error = HTTPError(
            url="https://example.com/file.txt",
            code=401,
            msg="Unauthorized",
            hdrs=None,
            fp=None,
        )

        with patch("urllib.request.urlopen") as mock_urlopen:
            mock_urlopen.side_effect = [transient_error, BytesIO(b"ok")]
            payload = _fetch_url_bytes("https://example.com/file.txt", retries=2, retry_delay_seconds=0)

        self.assertEqual(payload, b"ok")
        self.assertEqual(mock_urlopen.call_count, 2)

    def test_fetch_url_bytes_handles_multiple_transient_401_with_defaults(self) -> None:
        transient_error = HTTPError(
            url="https://example.com/file.txt",
            code=401,
            msg="Unauthorized",
            hdrs=None,
            fp=None,
        )

        with patch("urllib.request.urlopen") as mock_urlopen:
            mock_urlopen.side_effect = [
                transient_error,
                transient_error,
                transient_error,
                BytesIO(b"ok"),
            ]
            payload = _fetch_url_bytes("https://example.com/file.txt", retry_delay_seconds=0)

        self.assertEqual(payload, b"ok")
        self.assertEqual(mock_urlopen.call_count, 4)

    def test_cleans_ocr_noise_and_hyphen_breaks(self) -> None:
        text = """
CAPÍTULO I

Texto com hífen no final de linha apo-

1
2

Cf. João 14:2.

7

Santa Teresa d'Ávila – O castelo interior

sento seguinte.

_______

01
Parágrafo válido 8.

João 5: 2-9.
"""
        chapters = _split_plain_text_into_chapters(text)
        paragraphs = chapters[0]["sections"][0]["paragraphs"]
        self.assertEqual(
            paragraphs,
            [
                "Texto com hífen no final de linha aposento seguinte.",
                "Parágrafo válido.",
            ],
        )

    def test_parses_pocket_terco_html_into_chapters(self) -> None:
        html = """
<div class="single-page-livro_text">
  <div class="row" id="PARTE1-1">
    <div class="parte">Livro I - Avisos úteis</div>
  </div>
  <a name="CAPITULO1-1-1">&nbsp;</a>
  <div class="row">
    <div class="capitulo">Capítulo 1 - Da imitação de Cristo</div>
  </div>
  <div class="row-fluid numero">
    <div class="row">
      <div>1. Quem me segue não anda nas trevas.</div>
    </div>
  </div>
  <div class="row-fluid numero">
    <div class="row">
      <div>2. A doutrina de Cristo é mais excelente.</div>
    </div>
  </div>
  <div class="row" id="PARTE1-2">
    <div class="parte">Livro II - Vida interior</div>
  </div>
  <a name="CAPITULO1-2-1">&nbsp;</a>
  <div class="row">
    <div class="capitulo">Capítulo 1 - Da vida interior</div>
  </div>
  <div class="row-fluid numero">
    <div class="row">
      <div>Parágrafo de abertura.</div>
    </div>
  </div>
</div>
"""
        chapters = _parse_pocket_terco_html(html)

        self.assertEqual(len(chapters), 2)
        self.assertEqual(chapters[0]["title"], "Livro I - Avisos úteis")
        self.assertEqual(chapters[0]["sections"][0]["title"], "Capítulo 1 - Da imitação de Cristo")
        self.assertEqual(
            chapters[0]["sections"][0]["paragraphs"],
            [
                "1. Quem me segue não anda nas trevas.",
                "2. A doutrina de Cristo é mais excelente.",
            ],
        )
        self.assertEqual(chapters[1]["title"], "Livro II - Vida interior")


if __name__ == "__main__":
    unittest.main()
