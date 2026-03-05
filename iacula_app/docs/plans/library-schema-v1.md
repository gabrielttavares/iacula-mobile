# Library Schema V1

- `assets/books/library/index.json`: author catalog used for first-level browsing.
- `assets/books/library/authors/<author_id>.json`: work list per author.
- `assets/books/escriva/*.json`: full chapter content for works already ingested.

## Trust and PD fields

- `sourceRank`: confidence rank (`A`, `B`, `C`) for source provenance.
- `public_domain_verified`: legal/public-domain verification gate in ingestion manifest.
- `available`: whether full reading content is already shipped offline.
