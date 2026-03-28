#!/usr/bin/env python3
"""
Sync prayer content from scraped website data into app JSON files.

Usage:
    python3 sync_website.py            # Add/update only (no deletions)
    python3 sync_website.py --rebuild  # Full rebuild: remove extras, delete orphans
"""

import json
import os
import re
import sys
import unicodedata

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DETAILS_DIR = os.path.join(BASE_DIR, "assets/seed/prayers/details")
CATALOG_PATH = os.path.join(BASE_DIR, "assets/seed/prayers/pt-br/oracoes_catalog.json")
SCRAPED_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "scraped_website_2025.json")


def norm(s):
    """Normalize Unicode to NFC for consistent comparison."""
    return unicodedata.normalize('NFC', s.strip()) if s else ""


def slugify(text):
    """Generate a URL-safe slug from text."""
    text = text.lower()
    text = unicodedata.normalize('NFD', text)
    text = re.sub(r'[\u0300-\u036f]', '', text)
    text = re.sub(r'[^a-z0-9\s-]', '', text)
    text = re.sub(r'[\s]+', '-', text.strip())
    text = re.sub(r'-+', '-', text)
    return text


# Section mapping: website section name -> (app section_id, app section_title)
SECTION_MAP = {
    "Orações comuns": ("oracoes-comuns", "Orações Comuns"),
    "Ssma. Trindade": ("oracoes-santissima-trindade", "Orações à Santíssima Trindade"),
    "Adoração Eucarística": ("adoracao-eucaristica", "Adoração Eucarística"),
    "Espírito Santo": ("ao-espirito-santo", "Ao Espírito Santo"),
    "Nossa Senhora": ("oracoes-a-nossa-senhora", "Orações a Nossa Senhora"),
    "Antes da Missa": ("preparacao-santa-missa", "Preparação para a Santa Missa"),
    "Depois da Missa": ("acao-de-gracas-santa-missa", "Ação de Graças depois da Santa Missa"),
    "Outras devoções": ("outras-devocoes", "Outras Devoções, Hinos e Salmos"),
    "Hinos": ("hinos", "Hinos"),
    "Falecidos": ("oracoes-pelos-defuntos", "Orações pelos Defuntos"),
    "Doutrina": ("formulas-doutrina-catolica", "Fórmulas de Doutrina Católica"),
}

SECTION_TO_THEME = {
    "oracoes-comuns": ["oracoes-comuns"],
    "oracoes-santissima-trindade": ["santissima-trindade"],
    "adoracao-eucaristica": ["eucaristica"],
    "ao-espirito-santo": ["espirito-santo"],
    "oracoes-a-nossa-senhora": ["mariano"],
    "preparacao-santa-missa": ["missa-preparacao"],
    "acao-de-gracas-santa-missa": ["missa-acao-de-gracas"],
    "oracoes-diversas": ["diversos"],
    "outras-devocoes": ["devocoes"],
    "hinos": ["hinos"],
    "oracoes-pelos-defuntos": ["defuntos"],
    "formulas-doutrina-catolica": ["doutrina"],
}

# Title fixes for scraped data
TITLE_FIXES_LA = {
    "Ave maris stel la": "Ave maris stella",
    "Vexil regis la": "Vexilla regis",
    "Consecration to Mary": "Consecrátio ad B. Maríam Vírginem",
    "Rorate coeli": "Rorate caeli",
}

# Extra prayers to keep in oracoes-diversas (not from the website but user wants them)
KEEP_EXTRA_SLUGS = {
    "oracao-ao-anjo-da-guarda": ("oracoes-diversas", "Orações Diversas"),
    "oracao-para-boa-morte": ("oracoes-diversas", "Orações Diversas"),
    "aceitacao-da-morte": ("oracoes-diversas", "Orações Diversas"),
    "oracao-momento-da-morte": ("oracoes-diversas", "Orações Diversas"),
    "oracao-antes-do-estudo": ("oracoes-diversas", "Orações Diversas"),
    "oracao-pela-igreja-e-pela-patria": ("oracoes-diversas", "Orações Diversas"),
    "oracao-de-sao-bento": ("oracoes-diversas", "Orações Diversas"),
}


def convert_versicle_response(blocks):
    """
    Convert blocks starting with '. ' (scraped convention) to proper
    ℣ / ℟ Unicode markers, alternating versicle/response within each sequence.

    Special case: a single '. ' block after a break (like "Amen" after "Oremos")
    is treated as ℟ (response), not ℣.
    """
    # First pass: identify which blocks are versicle/response markers
    is_dot = [b.startswith(". ") or b.startswith(".") and len(b) > 1 and b[1] != '.' for b in blocks]

    result = []
    in_vr_sequence = False
    is_versicle = True

    for i, block in enumerate(blocks):
        if is_dot[i]:
            text = block.lstrip(". ")
            if not in_vr_sequence:
                in_vr_sequence = True
                # Check if this is a lone marker (no next dot block follows immediately)
                # If so, it's a response (e.g., "Amen" after "Oremos" prayer)
                next_is_dot = (i + 1 < len(blocks) and is_dot[i + 1])
                if not next_is_dot:
                    is_versicle = False  # lone marker = response
                else:
                    is_versicle = True

            marker = "℣" if is_versicle else "℟"
            result.append(f"{marker} {text}")
            is_versicle = not is_versicle
        else:
            in_vr_sequence = False
            is_versicle = True
            result.append(block)

    return result


def build_slug_table():
    """
    Build a complete mapping: (section_name, prayer_index) -> slug
    This uses the exact ordering from the scraped data to assign slugs deterministically.
    """
    mapping = {}

    # Orações comuns (9 prayers)
    mapping[("Orações comuns", 0)] = "sinal-da-cruz"
    mapping[("Orações comuns", 1)] = "pai-nosso"
    mapping[("Orações comuns", 2)] = "ave-maria"
    mapping[("Orações comuns", 3)] = "gloria"
    mapping[("Orações comuns", 4)] = "ato-de-contricao"
    mapping[("Orações comuns", 5)] = "confesso"
    mapping[("Orações comuns", 6)] = "credo"
    mapping[("Orações comuns", 7)] = "credo-apostolico"
    mapping[("Orações comuns", 8)] = "ao-anjo-da-guarda"

    # Ssma. Trindade (6 prayers)
    mapping[("Ssma. Trindade", 0)] = "simbolo-atanasiano"
    mapping[("Ssma. Trindade", 1)] = "te-deum"
    mapping[("Ssma. Trindade", 2)] = "trisagio-angelico"
    mapping[("Ssma. Trindade", 3)] = "ato-de-fe"
    mapping[("Ssma. Trindade", 4)] = "ato-de-esperanca"
    mapping[("Ssma. Trindade", 5)] = "ato-de-caridade"

    # Adoração Eucarística (7 prayers)
    mapping[("Adoração Eucarística", 0)] = "visita-ao-santissimo"
    mapping[("Adoração Eucarística", 1)] = "adoro-te-devote"
    mapping[("Adoração Eucarística", 2)] = "pange-lingua"
    mapping[("Adoração Eucarística", 3)] = "sacris-solemniis"
    mapping[("Adoração Eucarística", 4)] = "lauda-sion"
    mapping[("Adoração Eucarística", 5)] = "iesu-dulcis-memoria"
    mapping[("Adoração Eucarística", 6)] = "verbum-supernum"

    # Espírito Santo (3 prayers)
    mapping[("Espírito Santo", 0)] = "veni-sancte-spiritus"
    mapping[("Espírito Santo", 1)] = "veni-creator"
    mapping[("Espírito Santo", 2)] = "vinde-santo-espirito"

    # Nossa Senhora (12 prayers)
    mapping[("Nossa Senhora", 0)] = "angelus"
    mapping[("Nossa Senhora", 1)] = "regina-coeli"
    mapping[("Nossa Senhora", 2)] = "lembrai-vos"
    mapping[("Nossa Senhora", 3)] = "rosario-portugues"
    mapping[("Nossa Senhora", 4)] = "sob-a-tua-protecao"
    mapping[("Nossa Senhora", 5)] = "stabat-mater"
    mapping[("Nossa Senhora", 6)] = "consagracao-a-nossa-senhora"
    mapping[("Nossa Senhora", 7)] = "bendita-seja-a-tua-pureza"
    mapping[("Nossa Senhora", 8)] = "alma-redemptoris-mater"
    mapping[("Nossa Senhora", 9)] = "ave-regina-coelorum"
    mapping[("Nossa Senhora", 10)] = "magnificat"
    mapping[("Nossa Senhora", 11)] = "salve-rainha"

    # Antes da Missa (4 prayers)
    mapping[("Antes da Missa", 0)] = "preparacao-santa-missa"
    mapping[("Antes da Missa", 1)] = "a-sao-jose"
    mapping[("Antes da Missa", 2)] = "oracao-sao-tomas-de-aquino"
    mapping[("Antes da Missa", 3)] = "oracao-santo-ambrosio"

    # Depois da Missa (9 prayers)
    mapping[("Depois da Missa", 0)] = "oracao-sao-miguel-arcanjo"
    mapping[("Depois da Missa", 1)] = "oracao-sao-tomas-acao-de-gracas"
    mapping[("Depois da Missa", 2)] = "oracao-sao-boaventura"
    mapping[("Depois da Missa", 3)] = "oracao-papa-clemente-xi"
    mapping[("Depois da Missa", 4)] = "oracao-aojesus-crucificado"
    mapping[("Depois da Missa", 5)] = "invocacoes-santisimo-redentor"
    mapping[("Depois da Missa", 6)] = "oracao-santissima-virgem-maria-acao"
    mapping[("Depois da Missa", 7)] = "oracao-a-sao-jose-acao"
    mapping[("Depois da Missa", 8)] = "cântico-dos-três-jovens"

    # Outras devoções (9 prayers)
    mapping[("Outras devoções", 0)] = "salmo-2"
    mapping[("Outras devoções", 1)] = "salmo-50"
    mapping[("Outras devoções", 2)] = "salve-santa-cruz"
    mapping[("Outras devoções", 3)] = "via-sacra"
    mapping[("Outras devoções", 4)] = "antes-da-oracao-mental"
    mapping[("Outras devoções", 5)] = "leitura-espiritual"
    mapping[("Outras devoções", 6)] = "bencao-dos-alimentos"
    mapping[("Outras devoções", 7)] = "bencao-de-viagem"
    mapping[("Outras devoções", 8)] = "preces"

    # Hinos (12 prayers)
    mapping[("Hinos", 0)] = "ubi-caritas"
    mapping[("Hinos", 1)] = "pax-in-caelo"
    mapping[("Hinos", 2)] = "rorate-caeli"
    mapping[("Hinos", 3)] = "te-ioseph"
    mapping[("Hinos", 4)] = "benedictus"
    mapping[("Hinos", 5)] = "media-vita"
    mapping[("Hinos", 6)] = "ave-verum"
    mapping[("Hinos", 7)] = "ave-maris-stella"
    mapping[("Hinos", 8)] = "lux-aeterna"
    mapping[("Hinos", 9)] = "vexilla-regis"
    mapping[("Hinos", 10)] = "oremus-pro-pontifice"
    mapping[("Hinos", 11)] = "adeste-fideles"

    # Falecidos (3 prayers)
    mapping[("Falecidos", 0)] = "responso-portugues"
    mapping[("Falecidos", 1)] = "responso-latim"
    mapping[("Falecidos", 2)] = "responosrium-ii"

    # Doutrina (13 prayers)
    mapping[("Doutrina", 0)] = "mandamentos-da-caridade"
    mapping[("Doutrina", 1)] = "regra-de-ouro"
    mapping[("Doutrina", 2)] = "dez-mandamentos"
    mapping[("Doutrina", 3)] = "bem-aventurancas"
    mapping[("Doutrina", 4)] = "virtudes-teologais-formula"
    mapping[("Doutrina", 5)] = "virtudes-cardeais"
    mapping[("Doutrina", 6)] = "dons-espirito-santo"
    mapping[("Doutrina", 7)] = "frutos-espirito-santo"
    mapping[("Doutrina", 8)] = "mandamentos-da-igreja"
    mapping[("Doutrina", 9)] = "obras-misericordia-corporal"
    mapping[("Doutrina", 10)] = "obras-misericordia-espiritual"
    mapping[("Doutrina", 11)] = "vicios-capitais"
    mapping[("Doutrina", 12)] = "novissimos"

    return mapping


def fix_prayer(prayer):
    """Fix known issues in a prayer's data."""
    for key in ["laTitle", "ptBrTitle"]:
        if prayer.get(key, "") in TITLE_FIXES_LA:
            prayer[key] = TITLE_FIXES_LA[prayer[key]]
    return prayer


def main():
    rebuild = "--rebuild" in sys.argv

    # Load data
    with open(SCRAPED_PATH) as f:
        scraped = json.load(f)

    with open(CATALOG_PATH) as f:
        catalog = json.load(f)

    slug_table = build_slug_table()
    all_valid_slugs = set(slug_table.values()) | set(KEEP_EXTRA_SLUGS.keys())
    existing_ids = {entry["id"] for entry in catalog}
    existing_detail_files = set(os.listdir(DETAILS_DIR))

    new_prayers = []
    updated_prayers = []
    new_catalog_entries = []

    # Process each section from scraped data
    for section_name, prayers in scraped.items():
        if section_name not in SECTION_MAP:
            print(f"  SKIP: Unknown section '{section_name}'")
            continue

        section_id, section_title = SECTION_MAP[section_name]
        print(f"\n--- {section_name} ({section_id}) ---")

        for idx, prayer in enumerate(prayers):
            prayer = fix_prayer(prayer)
            slug = slug_table.get((section_name, idx))

            if slug is None:
                print(f"  WARN: No slug mapping for ({section_name}, {idx}): "
                      f"{prayer.get('ptBrTitle', '')} / {prayer.get('laTitle', '')}")
                continue

            pt_title = norm(prayer.get("ptBrTitle", ""))
            la_title = norm(prayer.get("laTitle", ""))
            languages = prayer.get("languages", [])
            pt_blocks = prayer.get("ptBrBlocks", [])
            la_blocks = prayer.get("laBlocks", [])

            # Convert '. ' markers to ℣/℟
            pt_blocks = convert_versicle_response([norm(b) for b in pt_blocks])
            la_blocks = convert_versicle_response([norm(b) for b in la_blocks])

            # Build detail data
            detail = {
                "slug": slug,
                "default_language": "pt-br" if "pt-br" in languages else "la",
                "titles": {},
                "blocks": {}
            }
            if pt_title:
                detail["titles"]["pt-br"] = pt_title
            if la_title:
                detail["titles"]["la"] = la_title
            if pt_blocks:
                detail["blocks"]["pt-br"] = pt_blocks
            if la_blocks:
                detail["blocks"]["la"] = la_blocks

            detail_path = os.path.join(DETAILS_DIR, f"{slug}.json")

            if f"{slug}.json" in existing_detail_files:
                # Update existing file
                with open(detail_path) as f:
                    existing = json.load(f)

                changed = False

                # Update titles
                for lang in ["pt-br", "la"]:
                    if lang in detail["titles"]:
                        old = existing.get("titles", {}).get(lang, "")
                        new = detail["titles"][lang]
                        if norm(old) != norm(new):
                            existing.setdefault("titles", {})[lang] = new
                            changed = True

                # Update blocks (always overwrite with scraped data)
                for lang in ["pt-br", "la"]:
                    if lang in detail["blocks"]:
                        existing.setdefault("blocks", {})[lang] = detail["blocks"][lang]
                        changed = True

                if changed:
                    with open(detail_path, "w") as f:
                        json.dump(existing, f, ensure_ascii=False, indent=2)
                        f.write("\n")
                    updated_prayers.append(slug)
                    print(f"  UPDATED: {slug}")
                else:
                    print(f"  OK: {slug} (no changes)")
            else:
                # Create new file
                with open(detail_path, "w") as f:
                    json.dump(detail, f, ensure_ascii=False, indent=2)
                    f.write("\n")
                new_prayers.append(slug)
                print(f"  NEW: {slug}")

            # Update or create catalog entry
            if slug not in existing_ids:
                content = ""
                if pt_blocks:
                    content = " ".join(pt_blocks[:2])[:200]
                elif la_blocks:
                    content = " ".join(la_blocks[:2])[:200]

                entry = {
                    "id": slug,
                    "title": pt_title if pt_title else la_title,
                    "content": content,
                    "section_id": section_id,
                    "section_title": section_title,
                    "languages": languages,
                    "theme": SECTION_TO_THEME.get(section_id, []),
                    "saints": []
                }

                # Assign saints
                title_lower = (pt_title + " " + la_title).lower()
                if "josé" in title_lower or "ioseph" in title_lower:
                    entry["saints"].append("sao-jose")
                if "nossa senhora" in title_lower or "maríam" in title_lower:
                    entry["saints"].append("virgem-maria")
                if "miguel" in title_lower or "míchaël" in title_lower:
                    entry["saints"].append("sao-miguel-arcanjo")
                if "anjo" in title_lower or "ángele" in title_lower:
                    entry["saints"].append("anjos")

                new_catalog_entries.append(entry)
                existing_ids.add(slug)
            else:
                # Update existing catalog entry: section assignment, languages
                for existing_entry in catalog:
                    if existing_entry["id"] == slug:
                        # Always update section to match scraped source
                        if existing_entry["section_id"] != section_id:
                            old = existing_entry["section_id"]
                            existing_entry["section_id"] = section_id
                            existing_entry["section_title"] = section_title
                            existing_entry["theme"] = SECTION_TO_THEME.get(section_id, [])
                            print(f"    MOVED: {slug} from {old} -> {section_id}")

                        # Update languages
                        if set(languages) - set(existing_entry.get("languages", [])):
                            existing_entry["languages"] = list(set(existing_entry.get("languages", [])) | set(languages))
                        break

    # --- REBUILD MODE: Remove extras ---
    if rebuild:
        print(f"\n=== REBUILD MODE ===")

        # Fix section assignments for KEEP_EXTRA_SLUGS
        for slug, (section_id, section_title) in KEEP_EXTRA_SLUGS.items():
            for entry in catalog:
                if entry["id"] == slug:
                    if entry["section_id"] != section_id:
                        old = entry["section_id"]
                        entry["section_id"] = section_id
                        entry["section_title"] = section_title
                        entry["theme"] = SECTION_TO_THEME.get(section_id, [])
                        print(f"  MOVED EXTRA: {slug} from {old} -> {section_id}")
                    break

        # Remove catalog entries not in valid slugs
        removed_entries = []
        new_catalog = []
        for entry in catalog:
            if entry["id"] in all_valid_slugs:
                new_catalog.append(entry)
            else:
                removed_entries.append(entry["id"])
                print(f"  REMOVED from catalog: {entry['id']} (was in {entry['section_id']})")

        # Also add new entries
        for new_entry in new_catalog_entries:
            # Find insert position
            target_section = new_entry["section_id"]
            insert_idx = len(new_catalog)

            last_same = -1
            for i, entry in enumerate(new_catalog):
                if entry["section_id"] == target_section:
                    last_same = i
            if last_same >= 0:
                insert_idx = last_same + 1

            new_catalog.insert(insert_idx, new_entry)

        catalog = new_catalog

        # Delete orphan detail files
        deleted_files = []
        for filename in os.listdir(DETAILS_DIR):
            if not filename.endswith('.json'):
                continue
            slug = filename.replace('.json', '')
            if slug not in all_valid_slugs:
                filepath = os.path.join(DETAILS_DIR, filename)
                os.remove(filepath)
                deleted_files.append(slug)
                print(f"  DELETED file: {filename}")

        print(f"\n  Removed {len(removed_entries)} catalog entries")
        print(f"  Deleted {len(deleted_files)} detail files")
    else:
        # Non-rebuild mode: just insert new catalog entries
        section_order_ids = [s[0] for s in SECTION_MAP.values()]

        for new_entry in new_catalog_entries:
            target_section = new_entry["section_id"]
            insert_idx = len(catalog)

            last_same = -1
            for i, entry in enumerate(catalog):
                if entry["section_id"] == target_section:
                    last_same = i

            if last_same >= 0:
                insert_idx = last_same + 1
            else:
                if target_section in section_order_ids:
                    target_order = section_order_ids.index(target_section)
                    for i, entry in enumerate(catalog):
                        if entry["section_id"] in section_order_ids:
                            entry_order = section_order_ids.index(entry["section_id"])
                            if entry_order > target_order:
                                insert_idx = i
                                break

            catalog.insert(insert_idx, new_entry)

    # Save catalog
    with open(CATALOG_PATH, "w") as f:
        json.dump(catalog, f, ensure_ascii=False, indent=2)
        f.write("\n")

    # Summary
    print(f"\n=== SUMMARY ===")
    print(f"New detail files: {len(new_prayers)}")
    for p in new_prayers:
        print(f"  + {p}")
    print(f"\nUpdated detail files: {len(updated_prayers)}")
    for p in updated_prayers:
        print(f"  ~ {p}")
    print(f"\nNew catalog entries: {len(new_catalog_entries)}")
    for e in new_catalog_entries:
        print(f"  + {e['id']} ({e['section_id']})")
    print(f"\nTotal catalog entries: {len(catalog)}")
    print(f"Total detail files: {len(os.listdir(DETAILS_DIR))}")

    # Verify
    all_catalog_ids = [e["id"] for e in catalog]
    all_detail_files = {f.replace('.json', '') for f in os.listdir(DETAILS_DIR) if f.endswith('.json')}

    missing_files = set(all_catalog_ids) - all_detail_files
    if missing_files:
        print(f"\nWARN: Catalog entries without detail files: {missing_files}")

    orphan_files = all_detail_files - set(all_catalog_ids)
    if orphan_files:
        print(f"\nWARN: Detail files without catalog entries: {orphan_files}")

    dupes = [id for id in all_catalog_ids if all_catalog_ids.count(id) > 1]
    if dupes:
        print(f"\nWARN: Duplicate catalog IDs: {set(dupes)}")

    print(f"\nDone!")


if __name__ == "__main__":
    main()
