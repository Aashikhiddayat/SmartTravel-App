# Security and privacy

- Never commit `.env`, credentials, Firebase service accounts, signing keys or private map packs.
- The Flutter app receives no `SUPABASE_SERVICE_ROLE_KEY`, `OPENAI_API_KEY`, or server-side provider secrets.
- Use HTTPS, constrained CORS origins, strict Supabase redirect URLs, and production rate limiting at a gateway/reverse proxy.
- Require a Supabase JWT outside demo mode. Remove/disable demo deployment before any public launch.
- RLS is enabled for every application table; use private buckets and short-lived signed URLs.
- Validate dimensions, IDs, date ranges and monetary amounts through Pydantic/database constraints.
- Request location permission only for a user-triggered feature. Store the minimum necessary event/location precision and delete it with the trip/account.
- Do not send raw receipts, full GPS histories or excessive third-party review text to an AI model.
- Threat-model group invites, storage paths, account deletion, auth redirects, abuse/rate limiting, compromised device tokens and export files before launch.

Safety data and emergency numbers require a verified jurisdiction-specific source. Never label seeded demo zones as official, and never present a lack of a match as proof that a place is safe.

