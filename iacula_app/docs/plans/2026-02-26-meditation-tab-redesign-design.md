# Meditação Tab Redesign — Design Document

## Objective

Replace the current Meditação tab (which only redirects to external links) with a native multi-type content experience supporting video, audio, and text-based daily meditations inside the app.

## Current State

`meditation_screen.dart` renders 3 `MeditationCard` widgets that each call `url_launcher` to open external URLs:
- Padre Cléber (SoundCloud audio)
- Padre Paulo Ricardo (YouTube video)
- Padre Pedro Willemsens (YouTube video)

This is bad UX — users leave the app entirely with no in-app consumption.

## Architecture

### Principle: Source-Agnostic Content Model

- One feature boundary: `meditation` in domain/application/infrastructure/presentation layers
- Domain entity is content-type aware but provider-agnostic
- No UI logic tied to YouTube/Spotify/iBreviary names
- Adapter ports per provider in data layer

### Data Source Phases

| Phase | Source | Editable Without App Release |
|-------|--------|------------------------------|
| Phase 1 (now) | Static JSON catalog (app asset) | No |
| Phase 2 (soon) | Supabase table, same schema | Yes |
| Phase 3 (if needed) | Background ingestion + editorial approval | Yes + automated |

### Playback Policy

- **Video**: Embedded player when reliable; fallback to in-app WebView + "Abrir fonte original" CTA
- **Audio**: Native audio player with play/pause/progress; fallback to source CTA
- **Text**: Rendered natively inside app (never WebView by default)

### Premium Gating

- Stays at use-case level (`CanAccessMeditationUseCase`) so rules are independent of type/provider
- Free users can browse feed; playback depth and gated collections can be switched on later without redesign
- UI supports future "Premium Collection" badges with no architecture change

---

## Content Model

```dart
/// Domain entity — source-agnostic
class MeditationItem {
  final String id;
  final MeditationType type;           // video | audio | text
  final String title;
  final String summary;
  final int? durationSec;
  final int? readingTimeSec;            // computed from word count for text
  final List<String> categoryTags;      // sleep, anxiety, focus, spiritual...
  final String sourceName;              // display only
  final String? sourceUrl;              // original provider URL
  final String? mediaUrl;               // playable URL if video/audio
  final String? imageUrl;               // app-curated thumbnail preferred
  final String? dateRef;                // "YYYY-MM-DD" for daily content
  final MeditationAvailability availability;
  final MeditationTextContent? textContent;
  final MeditationPremiumMeta premiumMeta;
  final MeditationProvenance provenance;
}

enum MeditationType { video, audio, text }

class MeditationAvailability {
  final String kind;                    // "evergreen" | "daily"
  final String? timezone;
}

class MeditationTextContent {
  final String body;                    // normalized content
  final String format;                  // "markdown" | "html" | "plain"
  final String language;                // "pt"
  final List<MeditationTextSection>? sections;
}

class MeditationTextSection {
  final String heading;
  final String body;
}

class MeditationPremiumMeta {
  final String tier;                    // "free" | "premium"
  final String? gateReason;
}

class MeditationProvenance {
  final String providerId;              // internal adapter id
  final String providerType;            // "channel" | "daily_text"
  final DateTime fetchedAt;
  final String canonicalHash;
}
```

### Design Decisions

1. **`format` field in textContent** — explicitly tracks `markdown | html | plain` so renderer behavior is deterministic, not guessed
2. **`readingTimeSec`** — computed from word count for text meditations; enables feed badge parity with audio/video duration and "short" filtering
3. **`providerType` in provenance** — distinguishes `channel` (YouTube/SoundCloud) from `daily_text` (Hablar con Dios/iBreviary) for operational debugging
4. **Timezone for daily content** — app-level configured timezone (`America/Sao_Paulo`), stored centrally in settings/config, not user-based or provider-based (Catholic daily readings follow liturgical calendar which is timezone-deterministic)

---

## UX Components

### Feed Screen (MeditationFeedScreen)

- **Header**: "Meditações" large title + subtle helper text ("Escolha pelo seu momento")
- **Filter chips** (horizontally scrollable): Todos, Sono, Ansiedade, Foco, Espiritual, Curta (≤5 min)
- **Optional secondary sorter**: Recomendados, Mais recentes, Duração curta
- **Loading**: Skeleton shimmer for feed
- **Empty state**: When no filters match
- **Error**: Non-blocking error banner for provider failures

### Feed Cards (same shell, type-specific accents)

| Element | Video | Audio | Text |
|---------|-------|-------|------|
| Glyph | Play circle | Waveform/headphone | Document |
| Badge | Duration | Duration | "Leitura do dia" / date + estimated reading time |
| Thumbnail | App-curated | App-curated | App-curated |
| Source badge | Small, subtle | Small, subtle | Small, subtle |
| Premium badge | If gated | If gated | If gated |

Same card component with type variant style map — avoids branching into provider-specific card trees.

### Detail Screen (MeditationDetailScreen)

**Common header**: title, source, tags, premium state, "Abrir fonte original" secondary CTA

| Type | Primary Content Area |
|------|---------------------|
| **Video** | Embedded player region; fallback to in-app WebView + source CTA if embedding fails |
| **Audio** | Native audio player with play/pause/progress bar; fallback to source CTA |
| **Text** | Rich text rendered natively (markdown/html normalized to app text blocks), typography controls, section anchors when available |

**Daily content behavior**: date selector (today, previous, next when available), deterministic "today" based on app-configured timezone (`America/Sao_Paulo`)

**Related content**: "Relacionados" carousel/list using same category/duration similarity

---

## Daily Text Content Strategy

### Provider Adapters

| Provider | URL Pattern | Type |
|----------|------------|------|
| Hablar con Dios | `hablarcondios.org/pt/meditacao-diaria/` | daily_text |
| iBreviary | `ibreviary.com/m2/breviario.php?s=ufficio_delle_letture` | daily_text |
| Meditatione | `meditatione.online/pt?date=YYYY-MM-DD` | daily_text |

### Fetch/Parse Pipeline (per adapter)

1. Fetch raw page/content for date
2. Parse/extract main meditation nodes (provider-specific CSS selectors)
3. Normalize to canonical `MeditationTextContent`
4. Sanitize + store cache (date + provider + hash)

### Maintainability

- Phase 1: parsing runs in-app with cached results
- Phase 2+: move parsing to backend edge function/service (less brittle than app-side updates)
- Keep parser contracts tested with fixture snapshots per provider/date

---

## Fallback Behavior (if fetch/scrape fails)

| Level | Strategy |
|-------|----------|
| L1 | Serve last successful cached entry for same provider/date |
| L2 | Serve same provider's nearest previous date with "conteúdo mais recente disponível" label |
| L3 | Serve curated internal daily text fallback (local JSON) — tab is never empty |
| L4 | Resilient empty state + retry + "Abrir fonte original" CTA |

Never hard-crash. Never block entire feed due to one provider failure.

---

## Analytics Events

### Shared
- `meditation_feed_viewed`
- `meditation_filter_applied`
- `meditation_item_opened`
- `meditation_premium_gate_shown`
- `meditation_open_original_tapped`

### Video
- `meditation_video_play_started`
- `meditation_video_play_completed`
- `meditation_video_embed_fallback_used`

### Audio
- `meditation_audio_play_started`
- `meditation_audio_play_25_50_75_100`
- `meditation_audio_embed_fallback_used`

### Text
- `meditation_text_viewed`
- `meditation_text_scroll_depth_25_50_75_100`
- `meditation_text_date_changed`

### Daily Reliability
- `meditation_daily_fetch_success`
- `meditation_daily_fetch_failed`
- `meditation_daily_cache_served`

---

## Testing Strategy

### Unit tests
- Content model serialization/deserialization from JSON
- Filter logic (by category, by type, by duration threshold)
- Daily deterministic selection
- Reading time computation from word count

### Repository/adapter tests
- JSON catalog parse succeeds for valid data
- Daily text adapter returns normalized content for fixture HTML
- Cache fallback serves stale entry when fetch fails
- Malformed entries are skipped safely

### Widget tests
- Feed renders cards with correct type glyphs
- Filter chips filter feed content
- Detail screen adapts layout per content type
- Premium gate renders for gated items
- Empty/error states render correctly

### Integration tests
- Feed → detail → playback/text render flow
- Daily date navigation (today/previous/next)
