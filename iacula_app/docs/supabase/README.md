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

Spiritual entry tables support soft-delete via `deleted_at` for tombstone sync.
