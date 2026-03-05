from __future__ import annotations

import re

from .base_source import BaseSource, SourceDescriptor


_MARKDOWN_LINK_RE = re.compile(r"\[(?P<label>[^\]]+)\]\((?P<url>https?://[^)]+)\)")
_POST_URL_RE = re.compile(r"https?://alexandriacatolica\.blogspot\.com/\d{4}/\d{2}/[^\s)]+")


class AlexandriaSource(BaseSource):
    descriptor = SourceDescriptor(id="alexandria_discovery", rank="C")

    def extract_candidates(self, markdown: str) -> list[dict[str, object]]:
        links = list(_MARKDOWN_LINK_RE.finditer(markdown))
        candidates: list[dict[str, object]] = []

        for index, match in enumerate(links):
            url = match.group("url")
            if not _POST_URL_RE.match(url):
                continue

            title_label = match.group("label")
            title = title_label.split("➜", maxsplit=1)[0].strip()
            downloads: list[str] = []
            for follow in links[index + 1 : index + 9]:
                follow_url = follow.group("url")
                if _POST_URL_RE.match(follow_url):
                    break
                if any(host in follow_url for host in ("mega.nz", "drive.google.com", "archive.org")):
                    downloads.append(follow_url)

            if not downloads:
                continue

            candidates.append(
                {
                    "title": title,
                    "post_url": url,
                    "download_urls": downloads,
                }
            )

        return candidates
