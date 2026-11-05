#!/usr/bin/env python3
"""
Normalize prayer blocks to the devotional-book markup rendered by the app.

Markup (one block = one paragraph):
    ℣ texto        versicle: said by whoever leads
    ℟ texto        response: said by everyone
    # Título       heading inside a prayer (e.g. "Ato de fé", "Mistérios gozosos")
    *texto*        rubric: instruction, not prayed (red italic). May also appear
                   inline at the end of a block, e.g. "… salva. *(três vezes)*"
    _texto_        abbreviated prayer cue, prayed in full (e.g. "_Ave-Maria…_")
    anything else  prayer text

The formatter is idempotent: already-marked blocks are left alone, so it can
run after every sync (sync_website.py calls `format_blocks`).

Usage:
    python3 tool/prayers/format_prayers.py           # rewrite all detail files
    python3 tool/prayers/format_prayers.py --check   # exit 1 if anything changes
"""

import json
import os
import re
import sys

DETAILS_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "assets/seed/prayers/details",
)

NBSP = " "

# --- Curated decisions --------------------------------------------------------
# Keys are the block text with NBSP → space and trimmed. Reviewed by hand over
# every heading/rubric candidate in the catalog (2026-11).

HEADINGS = {
    # pt-br
    "Ato de fé", "Ato de esperança", "Ato de caridade", "Ato de desejo",
    "Ato de caridade e arrependimento", "Ato de conformidade",
    "Súplica a Maria, Mãe dos Agonizantes", "Súplica a Maria",
    "Súplica aos Santos", "Súplica a Jesus",
    "Cântico dos Três Jovens", "Salmo 150", "Símbolo Atanasiano",
    "Mistérios gozosos", "Mistérios dolorosos", "Mistérios gloriosos",
    "Mistérios luminosos",
    "Outra oração", "Jaculatórias de desagravo", "Primeira dezena", "Antífona",
    "Oração introdutória", "Oração de aceitação da morte",
    "Oração para obter uma boa morte", "Oração para o momento da morte",
    "Comunhão espiritual",
    # la
    "Cánticum Trium Puerórum", "Psalmus 150", "Sýmbolum Athanasiánum",
    "Gaudii mysteria", "Doloris mysteria", "Gloriae mysteria", "Lucis mysteria",
    "Alabanzas de desagravio", "Prima decas", "Antíphona",
    "Communio spiritualis",
}

# Short notes that are not prayed: subtitles, seasons, attributions, sources.
RUBRICS = {
    # pt-br
    "Para o Tempo do Advento e do Natal", "Para o Tempo da Quaresma",
    "Para o Tempo Pascal", "Tempo do Advento", "Niceno-Constantinopolitano",
    "Dan. 3, 57-88 e 56", "Atribuída ao Papa Clemente XI",
    "Atribuída a Santo Andrés Apóstolo", "Sequência de Pentecostes",
    "Segunda-feira e sábado", "Terça-feira e sexta-feira",
    "Quarta-feira e domingo", "Quinta-feira", "Depois de cada mistério",
    # la
    "Hymnus Nativitatis", "Hymnus eucharisticus", "Nicaenum-Constantinopolitanum",
    "Dan. 3, 57-88 et 56", "A die 2 Februarii usque ad Feriam IV in Hebdomada sancta",
    "Tempus Quadragesimæ", "Tempus Adventus", "Pro Tempore Paschali",
    "Sub nómine Cleméntis PP. XI vulgáta", "Sancto Andreae Apostolo adscripta",
    "Ultimae duae strophae sunt hymnus 'Panis Angelicus'",
    "Ultimae duae strophae sunt 'O Salutáris Hóstia'", "In honore Sanctae Crucis",
    "Sequentia", "Initio", "In fine",
    "In feria secunda et sabbato", "In feria tertia et feria sexta",
    "In feria quarta et Dominica", "In feria quinta",
}

# Blocks ending in ":" that are prayer text, not instructions.
NOT_RUBRIC = {
    "A Vós, todos os Anjos, os Céus e todas as Potestades. A Vós, os Querubins e Serafins proclamam com incessantes vozes:",
    "Tibi omnes ángeli, tibi cæli et univérsæ potestátes: tibi chérubim et séraphim incessábili voce proclámant:",
    "Rorate coeli desúper, Et nubes plúant justum. Ne irascáris Dómine, ne ultra memíneris iniquitátis:",
}

# Fixes for import glitches (lost ℣/℟ markers, small-caps casing, separators).
# (slug, original text) → replacement, or None to drop the block.
FIXES = {
    ("preces", "℟ São Miguel."): "℣ São Miguel.",
    ("preces", ".. Rogai por nós."): "℟ Rogai por nós.",
    ("preces", "Salvai, meu Deus, os vossos servos, que em vós esperam."):
        "℟ Salvai, meu Deus, os vossos servos, que em vós esperam.",
    ("rosario-portugues", "________________"): None,
    ("vexilla-regis", "die 14 septembris: in hac triumphi gloria"):
        ["*Die 14 septembris:*", "in hac triumphi gloria"],
}

# Hymns imported as one block: split into stanzas of this many lines.
STANZA_LINES = {"sacris-solemniis": 4}

ABBREVIATED = re.compile(
    r"^(?:(?:Ave,?[ -]Maria|Pai[ -][Nn]osso|Glória(?: ao Pai)?|Pater noster|"
    r"Gloria Patri|Glória Patri)[.,]?\s*)+(?:…|\.\.\.)?\.?$"
)
TRAILING_RUBRIC = re.compile(
    r"\s*\(((?:três|duas|ter|bis)[^)]*vezes|em silêncio|ter repetitur oratio)\)\.?$"
)
ROLE_MARKER = re.compile(r"^([℣℟])[\s.:" + NBSP + r"]*")
INLINE_RESPONSE = re.compile(r"\s+℟[\s.]*")
MIXED_CASE_WORD = re.compile(r"\b\w*[a-zà-ú][A-ZÀ-Ú]\w*\b")


def _key(text):
    return " ".join(text.replace(NBSP, " ").split())


def _sentence_case(text):
    lower = text.lower()
    return lower[:1].upper() + lower[1:]


def _is_marked(block):
    return block[:1] in ("℣", "℟", "#", "*", "_")


def _fix_casing(block):
    """'OrEMOS' → 'Oremos', 'PrimeIra deZena' → 'Primeira dezena',
    'ORAÇÃO DE …' → 'Oração de …' (small-caps lost in the import)."""
    plain = _key(block)
    letters = [c for c in plain if c.isalpha()]
    if not letters or len(plain) > 80:
        return block
    if MIXED_CASE_WORD.search(plain) or (
        len(letters) > 3 and all(c.isupper() for c in letters)
    ):
        return _sentence_case(plain)
    return block


LITANY_RESPONSES = re.compile(
    r",\s+(nós vos pedimos, ouvi-nos|livrai-nos, Senhor|ouvi-nos, Senhor|"
    r"perdoai-nos, Senhor|tende piedade de nós|rogai por nós|"
    r"te rogámus, audi nos|líbera nos, Dómine|parce nobis, Dómine|"
    r"exáudi nos, Dómine|miserére nobis|oráte pro nobis|ora pro nobis)([.!]?)$"
)


def _mark_litany_response(slug, block):
    """'São Miguel, rogai por nós.' → 'São Miguel, ℟ rogai por nós.' so the
    people see their part on every invocation. A ℣ line that carries its own
    response ('℣ Cordeiro de Deus, …, perdoai-nos, Senhor.') is split in two."""
    if not slug.startswith("ladainha") or "℟" in block:
        return block
    if block.startswith("℣"):
        # Only the Agnus Dei carries the response on the versicle line; the
        # Kyrie ("℣ Senhor, tende piedade de nós.") is repeated whole.
        if "Cordeiro de Deus" not in block and "Agnus Dei" not in block:
            return block
        match = LITANY_RESPONSES.search(block)
        if not match:
            return block
        response = match.group(1)
        return f"{block[: match.start()]},\n℟ {response[:1].upper()}{response[1:]}{match.group(2)}"
    if _is_marked(block):
        return block
    return LITANY_RESPONSES.sub(r", ℟ \1\2", block)


# Hymns whose verse breaks were lost in the import ("memóriaDans",
# "regis,novum"): the boundary becomes a line break. In prose prayers the same
# glitch is a missing space.
HYMNS = {
    "adeste-fideles", "iesu-dulcis-memoria", "lauda-sion", "rorate-caeli",
    "sacris-solemniis", "te-ioseph", "ubi-caritas", "verbum-supernum",
    "vexilla-regis",
}
PROSE_GLUE = {"credo", "oracao-papa-clemente-xi", "salmo-2", "preces"}
# Verse breaks lost between two lowercase words; no pattern can find them, so
# they are listed by hand (checked against the Latin/Portuguese hymns).
GLUED_WORDS = {
    "verbum-supernum": ["discípulo|suis", "férculo|se", "spécie|carnem",
                        "substántiae|totum", "Domino|sit", "término|nobis"],
    "te-ioseph": ["céu|a", "morte|podem", "coniugem|admirans",
                  "Angelus|conceptum", "consecrat|palmamque", "perpetim|gratum"],
    "lauda-sion": ["pastórem|in", "vitális|hódie", "duodénæ|datum",
                   "decóra|mentis", "recólitur|huius", "expréssit|in",
                   "salútis|consecrámus", "sumptiónis|quam", "statúra|signáti",
                   "vidére|in", "sodales|fac"],
}
GLUED_CASE = re.compile(r"(?<=[a-zà-ÿæœ])(?=[A-ZÀ-ÚÆŒ])")
GLUED_PUNCT = re.compile(r"(?<=[,;:.!?])(?=[A-Za-zÀ-ÿæœÆŒ])")


def _restore_breaks(slug, block):
    for pair in GLUED_WORDS.get(slug, []):
        left, right = pair.split("|")
        block = block.replace(left + right, left + "\n" + right)
    if slug in HYMNS:
        for pattern in (GLUED_PUNCT, GLUED_CASE):
            block = pattern.sub("\n", block)
        block = re.sub(r"\n[ \u00a0]+", "\n", block)
    elif slug in PROSE_GLUE:
        block = GLUED_PUNCT.sub(" ", block)
    return block


def _split_lines(blocks):
    """One role per block: split multi-line blocks and inline '… ℟ …'."""
    out = []
    for block in blocks:
        lines = block.split("\n")
        # Hymn stanzas keep their line breaks; only ℣/℟ pairs are split.
        if not any(line.strip()[:1] in ("℣", "℟") for line in lines):
            lines = [block]
        for line in lines:
            line = line.strip()
            if not line:
                continue
            if line.startswith("℣") and "℟" in line[1:]:
                versicle, response = INLINE_RESPONSE.split(line, maxsplit=1)
                out.extend([versicle, "℟ " + response])
            else:
                out.append(line)
    return out


def _normalize_marker(block):
    match = ROLE_MARKER.match(block)
    if not match:
        return block
    return f"{match.group(1)} {block[match.end():].strip()}"


def _classify(slug, block):
    key = _key(block.replace("\n", " "))
    if (slug, key) in FIXES:
        return FIXES[(slug, key)]
    if _is_marked(block):
        return _normalize_marker(block)

    block = _fix_casing(block.strip())
    key = _key(block)

    if key in HEADINGS:
        return f"# {block}"
    if key in RUBRICS:
        return f"*{block}*"
    if ABBREVIATED.match(key):
        return f"_{block}_"

    trailing = TRAILING_RUBRIC.search(block)
    if trailing:
        body = block[: trailing.start()].rstrip()
        cue = f"_{body}_" if ABBREVIATED.match(_key(body)) else body
        return f"{cue} *({trailing.group(1)})*"

    is_instruction = (
        key.endswith(":")
        and len(key) < 200
        and key not in NOT_RUBRIC
        and not re.match(r"^\d+[.°º]", key)
    )
    if is_instruction or re.match(r"^\(.*\)\.?$", key) or key.startswith(
        "Outra fórmula do Confesso"
    ):
        return f"*{block.replace(':O', ': O')}*"
    return block


def _litany_cues(blocks):
    """Litanies print the response once and then only the invocations. Insert
    a rubric telling everyone what to answer before each run of bare
    invocations (3+ lines ending in a comma right after a ℟ line)."""
    out = []
    i = 0
    while i < len(blocks):
        block = blocks[i]
        out.append(block)
        if block.startswith("℟ "):
            run = 0
            while (
                i + 1 + run < len(blocks)
                and not _is_marked(blocks[i + 1 + run])
                and _key(blocks[i + 1 + run]).endswith(",")
            ):
                run += 1
            if run >= 3:
                response = _key(block[2:])
                out.append(f"*A cada invocação responde-se: {response}*"
                           if not _looks_latin(blocks[i + 1: i + 1 + run])
                           else f"*Ad singulas invocationes respondetur: {response}*")
        i += 1
    # Idempotency: drop duplicated cues if the formatter ran before.
    deduped = []
    for block in out:
        if deduped and block == deduped[-1] and block.startswith("*A") :
            continue
        deduped.append(block)
    return deduped


def _looks_latin(blocks):
    text = " ".join(blocks).lower()
    return any(w in text for w in ("ora pro nobis", "sancta ", "mater ", "virgo "))


def _stanzas(slug, block):
    size = STANZA_LINES.get(slug)
    lines = block.split("\n")
    if not size or len(lines) <= size + 1:
        return [block]
    return ["\n".join(lines[i:i + size]) for i in range(0, len(lines), size)]


def _plain_spaces(block):
    """The source pins short words to the next one with non-breaking spaces
    ("de\u00a0nós"), which forces ragged, gappy line wrapping on a phone."""
    block = block.replace(NBSP, " ").replace("\ufeff", "")
    return "\n".join(re.sub(r" {2,}", " ", line).strip() for line in block.split("\n"))


def format_blocks(slug, blocks):
    blocks = [_plain_spaces(b) for b in blocks]
    blocks = [_restore_breaks(slug, b) for b in blocks]
    blocks = _split_lines([_mark_litany_response(slug, b) for b in blocks])
    formatted = []
    for block in blocks:
        result = _classify(slug, block)
        if isinstance(result, list):
            formatted.extend(result)
        elif result is not None:
            formatted.extend(_stanzas(slug, result))
    if not any(b.startswith(("*A cada invocação", "*Ad singulas")) for b in formatted):
        formatted = _litany_cues(formatted)
    return formatted


def main():
    check = "--check" in sys.argv
    changed = []
    for name in sorted(os.listdir(DETAILS_DIR)):
        if not name.endswith(".json"):
            continue
        path = os.path.join(DETAILS_DIR, name)
        with open(path, encoding="utf-8") as f:
            raw = f.read()
        data = json.loads(raw)
        slug = data.get("slug", name[:-5])
        before = json.dumps(data, ensure_ascii=False)
        for lang, blocks in data.get("blocks", {}).items():
            data["blocks"][lang] = format_blocks(slug, blocks)
        if json.dumps(data, ensure_ascii=False) != before:
            changed.append(name)
            if not check:
                with open(path, "w", encoding="utf-8") as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)
                    if raw.endswith("\n"):
                        f.write("\n")
    print(f"{len(changed)} file(s) {'would change' if check else 'formatted'}")
    if check and changed:
        print("\n".join(changed))
        sys.exit(1)


if __name__ == "__main__":
    main()
