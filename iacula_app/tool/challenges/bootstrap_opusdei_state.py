#!/usr/bin/env python3
"""Open a headed browser so the user can solve Opus Dei Cloudflare and save state."""

from __future__ import annotations

import subprocess
from pathlib import Path

from iacula_app.tool.challenges.sync_pocket_terco_novenas import (
    BROWSER_STATE_PATH,
    OUTPUT_DIR,
    default_pwcli_path,
)


TARGET_URL = "https://opusdei.org/pt-br/article/novena-do-trabalho/"


def main() -> int:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    session = "opusdei-bootstrap"
    pwcli = default_pwcli_path()

    subprocess.run([pwcli, f"-s={session}", "open", TARGET_URL, "--headed"], check=True)
    input(
        "Complete the Cloudflare/browser challenge in the opened window, then press Enter to save browser state..."
    )
    subprocess.run(
        [pwcli, f"-s={session}", "state-save", str(BROWSER_STATE_PATH)],
        check=True,
    )
    subprocess.run([pwcli, f"-s={session}", "close"], check=False)
    print(f"Saved browser state to {BROWSER_STATE_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
