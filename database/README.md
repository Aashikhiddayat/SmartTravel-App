# Database

Run `migrations/001_initial.sql` once in a fresh Supabase project, then run `seed.sql`. The schema turns on RLS for every application table. Never give the Flutter app the `SUPABASE_SERVICE_ROLE_KEY`.

The API validates user sessions and enforces ownership before it reaches privileged operations; RLS remains the final database boundary. Use private storage and signed URLs for images. See [../docs/database.md](../docs/database.md) for the deployment sequence and the rationale for the demo-data limits.

