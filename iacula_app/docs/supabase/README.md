# Supabase setup (optional auth + sync)

## Required env

Run the app with:

```bash
fvm flutter run \
  --dart-define=AUTH_SYNC_ENABLED=true \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

If `AUTH_SYNC_ENABLED` is false (or URL/key are missing), app stays local-only.

## SQL execution order

1. `001_create_spiritual_data_tables.sql`
2. `002_enable_rls_and_policies.sql`
3. `003_updated_at_trigger.sql`
4. `004_create_user_premium_table.sql`
5. `005_create_user_local_state_tables.sql`
6. `006_enable_rls_user_local_state.sql`
7. `007_user_local_state_updated_at_trigger.sql`

Apply using Supabase SQL Editor or migration tooling.

## OAuth providers

Enable in Supabase Auth:
- Google
- Azure (Microsoft/Outlook)
- Apple

App UI shows Apple sign-in only on iOS.

## Redirect URI notes

Configure redirect URIs per platform in Supabase dashboard and native app setup:
- Android: your app scheme and host
- iOS: URL scheme + bundle id mapping

## Data model notes

Tables:
- `plan_of_life_entries`
- `examination_entries`
- `prayer_intention_entries`
- `user_premium`
- `user_settings`
- `user_last_delivered_card`
- `user_quote_state`

Spiritual entry tables support soft-delete via `deleted_at` for tombstone sync.

## Storage seed upload

Buckets used:
- `iacula_images`
- `iacula_audios`
- `iacula_texts`

Upload local seed assets (with image compression) using:

```bash
python scripts/supabase_upload_seed.py \
  --project-url https://YOUR-PROJECT.supabase.co \
  --service-role-key YOUR_SERVICE_ROLE_KEY \
  --seed-root assets/seed
```

Image runtime strategy (app):
- First try local `assets/seed/images/...` (offline-first).
- If source is remote URL or storage key, download and cache under device local storage.
- If an asset path is missing from bundle, fallback to Supabase Storage `iacula_images`.
