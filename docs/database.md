# Database and Supabase setup

1. Create a Supabase project and enable the PostGIS extension (the migration does this when permitted).
2. In the SQL editor, run `database/migrations/001_initial.sql`, then `database/seed.sql`.
3. In Authentication, enable Email/Password and configure the mobile deep-link/reset URL.
4. Create private buckets (`trip-photos`, `receipts`, `magazine-assets`) through the migration. Keep them private.
5. Put the URL/anon key in Flutter `--dart-define` values; keep the service-role key in the backend environment only.

The migration creates an `auth.users` trigger that synchronizes a minimal `public.users` row, profile and preferences. RLS covers direct mobile requests and API-accessed data. Test the following in a real project before release: user A cannot select user B's trips, expenses, emergency contacts, photos or storage objects by replacing a UUID/path.

Seeded places, reviews, zones and alerts are public app catalogue records but clearly marked as demo. Private sample trips/photos/expenses require a real Auth user to preserve foreign keys and RLS, so they are created by the demo flow rather than inserted using a fake user ID.

