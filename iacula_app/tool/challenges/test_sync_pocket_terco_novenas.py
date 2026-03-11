import json
import tempfile
import unittest
from pathlib import Path

from iacula_app.tool.challenges.sync_pocket_terco_novenas import (
    BROWSER_STATE_PATH,
    build_challenge_entry,
    fetch_item_html,
    load_manifest,
    parse_biblioteca_catolica_html,
    parse_opusdei_pdf_text,
    parse_padre_paulo_richardo_html,
    parse_pocket_terco_html,
    parse_source_html,
)


_HTML_POCKET_TERCO = """
<div id="content-download-pdf">
  <div class="terco-page-view__container">
    <table class='terco-page-view__table'>
      <tr><td><h2>Apresentação</h2>Primeira linha.<br><br>Segunda linha.</td></tr>
      <tr><td><h2>Quando rezar</h2>De 1 a 9 de maio.</td></tr>
      <tr><td><h2>1º dia - Virtude 1</h2>Texto 1.<br><br>Complemento 1.</td></tr>
      <tr><td><h2>2º dia - Virtude 2</h2>Texto 2.</td></tr>
      <tr><td><h2>3º dia - Virtude 3</h2>Texto 3.</td></tr>
      <tr><td><h2>4º dia - Virtude 4</h2>Texto 4.</td></tr>
      <tr><td><h2>5º dia - Virtude 5</h2>Texto 5.</td></tr>
      <tr><td><h2>6º dia - Virtude 6</h2>Texto 6.</td></tr>
      <tr><td><h2>7º dia - Virtude 7</h2>Texto 7.</td></tr>
      <tr><td><h2>8º dia - Virtude 8</h2>Texto 8.</td></tr>
      <tr><td><h2>9º dia - Virtude 9</h2>Texto 9.</td></tr>
    </table>
  </div>
</div>
"""

_HTML_WITH_EIGHT_DAYS = """
<div id="content-download-pdf">
  <div class="terco-page-view__container">
    <table class='terco-page-view__table'>
      <tr><td><h2>Apresentação</h2>Intro.</td></tr>
      <tr><td><h2>1º dia - Um</h2>Texto 1.</td></tr>
      <tr><td><h2>2º dia - Dois</h2>Texto 2.</td></tr>
      <tr><td><h2>3º dia - Três</h2>Texto 3.</td></tr>
      <tr><td><h2>4º dia - Quatro</h2>Texto 4.</td></tr>
      <tr><td><h2>5º dia - Cinco</h2>Texto 5.</td></tr>
      <tr><td><h2>6º dia - Seis</h2>Texto 6.</td></tr>
      <tr><td><h2>7º dia - Sete</h2>Texto 7.</td></tr>
      <tr><td><h2>8º dia - Oito</h2>Texto 8.</td></tr>
    </table>
  </div>
</div>
"""

_HTML_PADRE_PAULO_RICARDO = """
<html>
  <body>
    <div class="post-content container">
      <p>Esta é uma novena tradicional em honra a São José.</p>
      <blockquote><strong>Não me lembro...</strong></blockquote>
      <h3>Primeiro Dia</h3>
      <h4><em>São José, Pai Nutrício de Jesus</em></h4>
      <p>Texto dia 1.</p>
      <p><strong>V/. </strong>Rogai por nós.</p>
      <hr>
      <h3>Segundo Dia</h3>
      <h4><em>São José, Esposo da Virgem Maria</em></h4>
      <p>Texto dia 2.</p>
      <hr>
      <h3>Terceiro Dia</h3><h4><em>Título 3</em></h4><p>Texto 3.</p><hr>
      <h3>Quarto Dia</h3><h4><em>Título 4</em></h4><p>Texto 4.</p><hr>
      <h3>Quinto Dia</h3><h4><em>Título 5</em></h4><p>Texto 5.</p><hr>
      <h3>Sexto Dia</h3><h4><em>Título 6</em></h4><p>Texto 6.</p><hr>
      <h3>Sétimo Dia</h3><h4><em>Título 7</em></h4><p>Texto 7.</p><hr>
      <h3>Oitavo Dia</h3><h4><em>Título 8</em></h4><p>Texto 8.</p><hr>
      <h3>Nono Dia</h3><h4><em>Título 9</em></h4><p>Texto 9.</p>
    </div>
  </body>
</html>
"""

_HTML_BIBLIOTECA_CATOLICA = """
<html>
  <head>
    <meta name="description" content="Reze a novena a São Padre Pio." />
  </head>
  <body>
    <div class="entry-content">
      <p>Introdução à novena.</p>
      <p>Mais contexto.</p>
      <h2 class="wp-block-heading" id="quem-foi">Quem foi São Pio?</h2>
      <p>Texto biográfico.</p>
      <h2 class="wp-block-heading" id="dia-1"><strong>1º dia da novena a São Padre Pio</strong></h2>
      <p><em>Citação do dia 1.</em></p>
      <p>Texto dia 1.</p>
      <h3 class="wp-block-heading" id="oracoes-finais">Orações finais para todos os dias</h3>
      <p>Oração comum.</p>
      <h2 class="wp-block-heading" id="dia-2"><strong>2º dia da novena a São Padre Pio</strong></h2>
      <p>Texto dia 2.</p>
      <p><strong>Reza-se as orações finais.</strong></p>
      <h2 class="wp-block-heading" id="dia-3"><strong>3º dia da novena a São Padre Pio</strong></h2><p>Texto dia 3.</p>
      <h2 class="wp-block-heading" id="dia-4"><strong>4º dia da novena a São Padre Pio</strong></h2><p>Texto dia 4.</p>
      <h2 class="wp-block-heading" id="dia-5"><strong>5º dia da novena a São Padre Pio</strong></h2><p>Texto dia 5.</p>
      <h2 class="wp-block-heading" id="dia-6"><strong>6º dia da novena a São Padre Pio</strong></h2><p>Texto dia 6.</p>
      <h2 class="wp-block-heading" id="dia-7"><strong>7º dia da novena a São Padre Pio</strong></h2><p>Texto dia 7.</p>
      <h2 class="wp-block-heading" id="dia-8"><strong>8º dia da novena a São Padre Pio</strong></h2><p>Texto dia 8.</p>
      <h2 class="wp-block-heading" id="dia-9"><strong>9º dia da novena a São Padre Pio</strong></h2><p>Texto dia 9.</p>
    </div>
  </body>
</html>
"""

_OPUSDEI_PDF_TEXT_PRIMEIRO_DIA = """
NOVENA DO TRABALHO
Apresentação
O objetivo desta novena é pedir a Deus por intercessão de São Josemaria.

1

Primeiro dia. Trabalho, caminho de santidade
Reflexão
Texto do dia 1.
Pedido
Pedido do dia 1.

2

Segundo dia. Trabalhar por amor a Deus
Texto do dia 2.

3

Terceiro dia. Trabalhar com ordem e constância
Texto do dia 3.

4

Quarto dia. Trabalho bem acabado
Texto do dia 4.

5

Quinto dia. Todos os trabalhos honestos são dignos
Texto do dia 5.

6

Sexto dia. Trabalhar em companhia de Deus e com reta intenção
Texto do dia 6.

7

Sétimo dia. Amadurecer nas virtudes através do trabalho
Texto do dia 7.

8

Oitavo dia. Trabalhar é servir, ajudar os outros
Texto do dia 8.

9

Nono dia. Fazer apostolado com o nosso trabalho
Texto do dia 9.
"""

_OPUSDEI_PDF_TEXT_NUMERIC_DAYS = """
NOVENA DOS ENFERMOS
Imprimatur
Linha editorial que deve ser removida.

1º DIA
Deus nos ama
Reflexão: Palavras de São Josemaria Escrivá
É preciso convencer-se de que Deus está junto de nós continuamente.

-5-

Pedido
Senhor, aumenta a minha fé.

2º DIA
Aceitar a vontade de Deus
Texto do dia 2.

3º DIA
Confiar na providência
Texto do dia 3.

4º DIA
Rezar com perseverança
Texto do dia 4.

5º DIA
Oferecer a dor
Texto do dia 5.

6º DIA
Buscar a paz de Cristo
Texto do dia 6.

7º DIA
Aceitar a cruz
Texto do dia 7.

8º DIA
Servir com esperança
Texto do dia 8.

9º DIA
Viver com abandono
Texto do dia 9.
"""

_OPUSDEI_PDF_TEXT_WITH_TOC = """
Novena do trabalho
Índice
Primeiro dia. Trabalho, caminho de santidade
Segundo dia. Trabalhar por amor a Deus
Terceiro dia. Trabalhar com ordem e constância
Quarto dia. Trabalho bem acabado
Quinto dia. Todos os trabalhos honestos são dignos
Sexto dia. Trabalhar em companhia de Deus e com reta intenção
Sétimo dia. Amadurecer nas virtudes através do trabalho
Oitavo dia. Trabalhar é servir, ajudar os outros
Nono dia. Fazer apostolado com o nosso trabalho

Apresentação
Cada dia da novena consiste em duas partes
1. A primeira é uma seleção de textos de São Josemaria para reflexão, exame e oração.
2. A segunda parte consiste em uma série de intenções.

PRIMEIRO DIA
Trabalho, caminho de santidade

Reflexão: Palavras de São Josemaria Escrivá
Texto do dia 1.

SEGUNDO DIA
Trabalhar por amor a Deus
Texto do dia 2.

TERCEIRO DIA
Trabalhar com ordem e constância
Texto do dia 3.

QUARTO DIA
Trabalho bem acabado
Texto do dia 4.

QUINTO DIA
Todos os trabalhos honestos são dignos
Texto do dia 5.

SEXTO DIA
Trabalhar em companhia de Deus e com reta intenção
Texto do dia 6.

SÉTIMO DIA
Amadurecer nas virtudes através do trabalho
Texto do dia 7.

OITAVO DIA
Trabalhar é servir, ajudar os outros
Texto do dia 8.

NONO DIA
Fazer apostolado com o nosso trabalho
Texto do dia 9.
"""


class SourceParserTest(unittest.TestCase):
    def test_parse_pocket_terco_html_collects_intro_and_nine_days(self):
        parsed = parse_pocket_terco_html(_HTML_POCKET_TERCO)

        self.assertEqual(
            parsed["description"],
            "Primeira linha.\n\nSegunda linha.\n\nDe 1 a 9 de maio.",
        )
        self.assertEqual(parsed["days"][0]["title"], "Virtude 1")
        self.assertEqual(parsed["days"][0]["readingText"], "Texto 1.\n\nComplemento 1.")

    def test_parse_pocket_terco_html_returns_none_when_day_count_is_not_nine(self):
        self.assertIsNone(parse_pocket_terco_html(_HTML_WITH_EIGHT_DAYS))

    def test_parse_padre_paulo_richardo_html_reads_h3_h4_day_sections(self):
        parsed = parse_padre_paulo_richardo_html(_HTML_PADRE_PAULO_RICARDO)

        self.assertEqual(parsed["description"], "Esta é uma novena tradicional em honra a São José.\n\nNão me lembro...")
        self.assertEqual(parsed["days"][0]["title"], "São José, Pai Nutrício de Jesus")
        self.assertEqual(parsed["days"][0]["readingText"], "Texto dia 1.\n\nV/. Rogai por nós.")
        self.assertEqual(parsed["days"][1]["title"], "São José, Esposo da Virgem Maria")

    def test_parse_biblioteca_catolica_html_reads_wordpress_day_sections(self):
        parsed = parse_biblioteca_catolica_html(_HTML_BIBLIOTECA_CATOLICA)

        self.assertEqual(
            parsed["description"],
            "Introdução à novena.\n\nMais contexto.\n\nQuem foi São Pio?\n\nTexto biográfico.",
        )
        self.assertEqual(parsed["days"][0]["title"], "1º dia da novena a São Padre Pio")
        self.assertEqual(
            parsed["days"][0]["readingText"],
            "Citação do dia 1.\n\nTexto dia 1.\n\nOrações finais para todos os dias\n\nOração comum.",
        )
        self.assertEqual(parsed["days"][1]["readingText"], "Texto dia 2.\n\nReza-se as orações finais.")

    def test_parse_source_html_dispatches_by_source(self):
        parsed = parse_source_html("biblioteca_catolica", _HTML_BIBLIOTECA_CATOLICA)

        self.assertEqual(parsed["days"][0]["dayNumber"], 1)
        self.assertEqual(parsed["days"][8]["dayNumber"], 9)

    def test_parse_opusdei_pdf_text_reads_intro_and_primeiro_dia_headings(self):
        parsed = parse_opusdei_pdf_text(_OPUSDEI_PDF_TEXT_PRIMEIRO_DIA)

        self.assertEqual(parsed["description"], "Apresentação\n\nO objetivo desta novena é pedir a Deus por intercessão de São Josemaria.")
        self.assertEqual(parsed["days"][0]["title"], "Trabalho, caminho de santidade")
        self.assertEqual(parsed["days"][0]["readingText"], "Reflexão\n\nTexto do dia 1.\n\nPedido\n\nPedido do dia 1.")
        self.assertEqual(parsed["days"][8]["title"], "Fazer apostolado com o nosso trabalho")

    def test_parse_opusdei_pdf_text_reads_numeric_day_headings_and_cleans_page_numbers(self):
        parsed = parse_opusdei_pdf_text(_OPUSDEI_PDF_TEXT_NUMERIC_DAYS)

        self.assertEqual(parsed["days"][0]["title"], "Deus nos ama")
        self.assertNotIn("-5-", parsed["days"][0]["readingText"])
        self.assertIn("Senhor, aumenta a minha fé.", parsed["days"][0]["readingText"])

    def test_parse_opusdei_pdf_text_returns_none_when_day_count_is_not_nine(self):
        self.assertIsNone(parse_opusdei_pdf_text(_OPUSDEI_PDF_TEXT_PRIMEIRO_DIA.replace("Nono dia. Fazer apostolado com o nosso trabalho\nTexto do dia 9.\n", "")))

    def test_parse_source_html_dispatches_opusdei_pdf_source(self):
        parsed = parse_source_html("opusdei_pdf", _OPUSDEI_PDF_TEXT_PRIMEIRO_DIA)

        self.assertEqual(parsed["days"][0]["dayNumber"], 1)
        self.assertEqual(parsed["days"][8]["dayNumber"], 9)

    def test_parse_opusdei_pdf_text_ignores_table_of_contents_and_numbered_intro_lists(self):
        parsed = parse_opusdei_pdf_text(_OPUSDEI_PDF_TEXT_WITH_TOC)

        self.assertEqual(parsed["description"], "Apresentação\n\nCada dia da novena consiste em duas partes\n\n1. A primeira é uma seleção de textos de São Josemaria para reflexão, exame e oração.\n\n2. A segunda parte consiste em uma série de intenções.")
        self.assertEqual(parsed["days"][0]["title"], "Trabalho, caminho de santidade")
        self.assertEqual(parsed["days"][0]["readingText"], "Reflexão: Palavras de São Josemaria Escrivá\n\nTexto do dia 1.")

    def test_build_challenge_entry_generates_reused_prompt(self):
        parsed = parse_pocket_terco_html(_HTML_POCKET_TERCO)

        challenge = build_challenge_entry(
            challenge_id="novena_teste",
            title="Novena de Teste",
            category="novena",
            parsed=parsed,
        )

        prompts = {day["reflectionPrompt"] for day in challenge["content"]}
        self.assertEqual(prompts, {"Que graca desejo pedir por intercessao nesta novena de teste?"})


class ManifestAndFetchTest(unittest.TestCase):
    def test_load_manifest_reads_source_metadata(self):
        with tempfile.TemporaryDirectory() as tmp_dir:
            path = Path(tmp_dir) / "manifest.json"
            path.write_text(
                json.dumps(
                    [
                        {
                            "id": "novena_test",
                            "title": "Novena Teste",
                            "url": "https://example.com",
                            "source": "pocket_terco",
                            "access_mode": "http",
                        }
                    ]
                ),
                encoding="utf-8",
            )

            manifest = load_manifest(path)

        self.assertEqual(manifest[0]["source"], "pocket_terco")
        self.assertEqual(manifest[0]["access_mode"], "http")

    def test_fetch_item_html_uses_http_fetcher_for_http_sources(self):
        calls = []

        html = fetch_item_html(
            {
                "url": "https://example.com",
                "source": "padre_paulo_ricardo",
                "access_mode": "http",
            },
            http_fetcher=lambda url: calls.append(url) or "<html></html>",
        )

        self.assertEqual(html, "<html></html>")
        self.assertEqual(calls, ["https://example.com"])

    def test_fetch_item_html_extracts_text_for_opusdei_pdf_sources(self):
        calls = []

        text = fetch_item_html(
            {
                "url": "https://example.com/novena.pdf",
                "source": "opusdei_pdf",
                "access_mode": "http",
            },
            http_fetcher=lambda url: calls.append(url) or b"%PDF-1.4",
            pdf_text_fetcher=lambda content: "Primeiro dia. Título\nTexto 1.\nSegundo dia. Título\nTexto 2.\nTerceiro dia. Título\nTexto 3.\nQuarto dia. Título\nTexto 4.\nQuinto dia. Título\nTexto 5.\nSexto dia. Título\nTexto 6.\nSétimo dia. Título\nTexto 7.\nOitavo dia. Título\nTexto 8.\nNono dia. Título\nTexto 9.",
        )

        self.assertIn("Primeiro dia. Título", text)
        self.assertEqual(calls, ["https://example.com/novena.pdf"])

    def test_fetch_item_html_raises_when_opusdei_pdf_extraction_is_empty(self):
        with self.assertRaises(ValueError):
            fetch_item_html(
                {
                    "url": "https://example.com/novena.pdf",
                    "source": "opusdei_pdf",
                    "access_mode": "http",
                },
                http_fetcher=lambda url: b"%PDF-1.4",
                pdf_text_fetcher=lambda content: "",
            )

    def test_fetch_item_html_requires_state_for_browser_mode(self):
        with tempfile.TemporaryDirectory() as tmp_dir:
            state_path = Path(tmp_dir) / "missing-state.json"
            with self.assertRaises(FileNotFoundError):
                fetch_item_html(
                    {
                        "url": "https://opusdei.org/example",
                        "source": "opusdei",
                        "access_mode": "browser_state",
                    },
                    state_path=state_path,
                    browser_fetcher=lambda url, state: "<html></html>",
                )

    def test_fetch_item_html_uses_browser_fetcher_when_state_exists(self):
        with tempfile.TemporaryDirectory() as tmp_dir:
            state_path = Path(tmp_dir) / "opusdei-state.json"
            state_path.write_text('{"cookies":[]}', encoding="utf-8")
            calls = []

            html = fetch_item_html(
                {
                    "url": "https://opusdei.org/example",
                    "source": "opusdei",
                    "access_mode": "browser_state",
                },
                state_path=state_path,
                browser_fetcher=lambda url, state: calls.append((url, state)) or "<html>ok</html>",
            )

        self.assertEqual(html, "<html>ok</html>")
        self.assertEqual(calls, [("https://opusdei.org/example", state_path)])

    def test_default_browser_state_path_points_to_output_playwright(self):
        self.assertTrue(str(BROWSER_STATE_PATH).endswith("output/playwright/opusdei-state.json"))


if __name__ == "__main__":
    unittest.main()
