# Home + Orações Rework Design

## Objective
Implement a focused rework of the Home and Orações experience to remove redundant UI, fix broken navigation/layout behavior, and move prayer content to a JSON-backed source with dynamic thematic and saint filtering.

## Scope
- Home screen behavior and composition in `lib/features/home/presentation/home_screen.dart`.
- Orações content source and rendering pipeline.
- Liturgia quick-action navigation reliability.
- Dynamic filtering support for `Orações temáticas` and `Orações de Santos`.

Out of scope:
- Premium entitlement logic changes.
- Remote backend/sync changes.
- New personalization/recommendation engine.

## Architecture
- Keep the existing app shell and route map.
- Standardize Liturgia navigation from Home to the canonical `LiturgiaScreen.routeName` route.
- Introduce a typed, JSON-backed prayer catalog source (asset-based) for Home prayer sections and Orações listing flows.
- Keep filtering logic in repository/use case layer instead of widget layer.
- Keep current screen composition patterns and Cupertino design language.

## UX and Component Design

### 1) Local Mode Warning
- In local mode, the yellow warning banner must not render at all.

### 2) Quick Actions Row
- Replace the current 3-card row with 4 actions in one row:
  - `Orações`
  - `Liturgia`
  - `Rosário 📿`
  - `Novenas`
- Remove `Premium` from this row.

### 3) Liturgia Navigation
- Ensure tapping `Liturgia` always opens full `LiturgiaScreen` content.
- Route invocation should be unified to avoid dead-end behavior.

### 4) Hero Card
- Remove hard truncation that clips longer text.
- Replace fixed-height behavior with flexible/adaptive layout so content wraps safely.
- Ensure hero image is loaded from assets when available.
- Keep graceful fallback surface if image fails.

### 5) Section Cleanup
- Remove `Destaques` section completely.
- Replace `Orações diárias` with `Sugestão do Dia`.
- Keep `Orações temáticas` and `Orações de Santos`, now sourced dynamically from JSON tags.

## Data Model and Source

### Source Conversion
- Convert `/Users/gabrielttav/Downloads/oracoes.txt` into a clean JSON asset included in app assets.
- Remove formatting noise (page markers, control chars, index artifacts).

### Required Prayer Entry Schema
Each prayer entry must follow:

```json
{
  "id": "",
  "title": "",
  "content": "",
  "theme": ["esperança", "misericórdia", "gratidão"],
  "saints": ["São José", "São Francisco"]
}
```

Notes:
- Tag values will be in Portuguese.
- `theme` enables thematic filtering.
- `saints` enables saint-based filtering.

## Data Flow
- Asset repository loads and parses prayer catalog JSON.
- Use cases expose:
  - list all prayers
  - list prayers by theme tag
  - list prayers by saint tag
  - deterministic `Sugestão do Dia`
- Home sections consume these use cases.
- Orações screen content is rendered dynamically from this same source.

## Error Handling
- If JSON is missing/invalid, render resilient empty/error states (no crash).
- Skip malformed entries while continuing to render valid entries.
- Empty tag arrays must not break filtering or UI.
- Missing hero image falls back to decorative background while preserving readable text and CTA.

## Testing Strategy

### Widget tests
- Home does not show local warning banner in local mode.
- Home quick-action row contains `Orações`, `Liturgia`, `Rosário 📿`, `Novenas`.
- `Destaques` is absent and `Sugestão do Dia` is present.
- Liturgia card opens `LiturgiaScreen`.
- Hero text wrapping regression test for long text visibility.

### Repository/parser tests
- JSON parse succeeds for valid catalog.
- Required fields map correctly.
- Filters by `theme` and `saints` return correct subsets.
- Malformed entries are skipped safely.

### Asset behavior tests
- Hero image path renders when valid.
- Fallback path renders when missing.

## Implementation Guidance
- Prefer incremental replacement over broad refactor.
- Keep behavior deterministic and local-first.
- Apply YAGNI: avoid adding features not required by this request.
