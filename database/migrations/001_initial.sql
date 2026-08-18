-- SMART TRIP initial Supabase schema. Run in the Supabase SQL editor or via Supabase CLI.
-- The application uses auth.users for identity; public.users is a synchronized app profile row.
create extension if not exists pgcrypto;
create extension if not exists postgis;

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.users(id) on delete cascade,
  name text,
  phone text,
  country text,
  preferred_language text not null default 'en',
  budget_preference text not null default 'Balanced',
  travel_style text not null default 'Balanced',
  food_preferences jsonb not null default '[]'::jsonb,
  interests jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.destinations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  country text,
  latitude double precision,
  longitude double precision,
  created_at timestamptz not null default now()
);

create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.users(id) on delete cascade,
  title text not null check (char_length(title) between 2 and 120),
  destination text not null,
  destination_id uuid references public.destinations(id) on delete set null,
  start_date date not null,
  end_date date not null check (end_date >= start_date),
  budget numeric(12,2) not null check (budget > 0),
  currency char(3) not null default 'INR',
  status text not null default 'upcoming' check (status in ('upcoming','active','completed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.trip_members (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','editor','member')),
  joined_at timestamptz not null default now(),
  unique(trip_id, user_id)
);

create table if not exists public.places (
  id uuid primary key default gen_random_uuid(),
  external_place_id text unique,
  name text not null,
  category text not null check (category in ('food','stay','attraction','essential')),
  description text,
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  location geography(point, 4326) generated always as (st_setsrid(st_makepoint(longitude, latitude), 4326)::geography) stored,
  rating numeric(2,1) check (rating between 0 and 5),
  price_level smallint check (price_level between 1 and 4),
  address text,
  website text,
  phone text,
  opening_hours jsonb,
  source text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.accommodations (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null unique references public.places(id) on delete cascade,
  amenity_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.restaurants (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null unique references public.places(id) on delete cascade,
  dietary_options jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.places(id) on delete cascade,
  external_review_id text,
  rating numeric(2,1) check (rating between 0 and 5),
  text text,
  author_name text,
  published_at timestamptz,
  source text not null,
  unique(place_id, external_review_id)
);

create table if not exists public.recommendations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  trip_id uuid references public.trips(id) on delete cascade,
  place_id uuid not null references public.places(id) on delete cascade,
  recommendation_type text not null,
  score numeric(6,2) not null,
  reason text,
  generated_by text not null,
  score_breakdown jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.itinerary_days (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  day_number integer not null check (day_number > 0),
  date date not null,
  summary text,
  unique(trip_id, day_number)
);

create table if not exists public.itinerary_items (
  id uuid primary key default gen_random_uuid(),
  itinerary_day_id uuid not null references public.itinerary_days(id) on delete cascade,
  place_id uuid references public.places(id) on delete set null,
  start_time time,
  end_time time,
  duration_minutes integer check (duration_minutes >= 0),
  travel_time_minutes integer check (travel_time_minutes >= 0),
  status text not null default 'planned' check (status in ('planned','done','skipped')),
  notes text,
  ai_reason text
);

create table if not exists public.receipts (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  image_path text not null,
  ocr_text text,
  merchant text,
  total_amount numeric(12,2),
  currency char(3),
  receipt_date date,
  confidence numeric(4,3) check (confidence between 0 and 1),
  created_at timestamptz not null default now()
);

create table if not exists public.expense_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  icon text,
  created_at timestamptz not null default now()
);

create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  category text not null check (category in ('Transport','Accommodation','Food','Tickets','Shopping','Emergency','Other')),
  amount numeric(12,2) not null check (amount > 0),
  currency char(3) not null default 'INR',
  description text not null,
  merchant text,
  expense_date date not null,
  latitude double precision,
  longitude double precision,
  receipt_id uuid unique references public.receipts(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.photos (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  storage_path text not null unique,
  thumbnail_path text,
  captured_at timestamptz,
  latitude double precision,
  longitude double precision,
  width integer check (width > 0),
  height integer check (height > 0),
  created_at timestamptz not null default now()
);

create table if not exists public.photo_metadata (
  id uuid primary key default gen_random_uuid(),
  photo_id uuid not null unique references public.photos(id) on delete cascade,
  detected_place text,
  detected_category text,
  caption text,
  ai_tags jsonb not null default '[]'::jsonb,
  confidence numeric(4,3) check (confidence between 0 and 1)
);

create table if not exists public.travel_timeline (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  event_type text not null,
  event_time timestamptz not null,
  latitude double precision,
  longitude double precision,
  title text not null,
  description text,
  photo_id uuid references public.photos(id) on delete set null,
  expense_id uuid references public.expenses(id) on delete set null
);

create table if not exists public.magazines (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  title text not null,
  subtitle text,
  cover_image_path text,
  status text not null default 'draft' check (status in ('draft','generating','ready','failed')),
  generated_at timestamptz
);

create table if not exists public.magazine_pages (
  id uuid primary key default gen_random_uuid(),
  magazine_id uuid not null references public.magazines(id) on delete cascade,
  page_number integer not null check (page_number > 0),
  page_type text not null,
  title text,
  content text,
  image_paths jsonb not null default '[]'::jsonb,
  layout_data jsonb not null default '{}'::jsonb,
  unique(magazine_id, page_number)
);

create table if not exists public.danger_zones (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null,
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  radius_meters numeric(10,2) not null check (radius_meters > 0),
  risk_level text not null check (risk_level in ('caution','high')),
  source text not null,
  source_url text,
  active boolean not null default true,
  is_demo boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.safety_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  trip_id uuid references public.trips(id) on delete set null,
  danger_zone_id uuid references public.danger_zones(id) on delete set null,
  latitude double precision not null,
  longitude double precision not null,
  distance_meters numeric(10,2),
  risk_level text,
  event_type text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.emergency_contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  name text not null,
  phone text not null,
  relationship text,
  is_primary boolean not null default false
);

create table if not exists public.alerts (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references public.trips(id) on delete cascade,
  alert_type text not null,
  title text not null,
  message text not null,
  severity text not null check (severity in ('info','caution','danger')),
  source text not null,
  valid_from timestamptz,
  valid_until timestamptz,
  is_demo boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.saved_offline_regions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  trip_id uuid references public.trips(id) on delete cascade,
  provider text not null,
  region_name text not null,
  style_url text,
  pack_identifier text,
  downloaded_at timestamptz not null default now(),
  expires_at timestamptz
);

create table if not exists public.user_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.users(id) on delete cascade,
  location_tracking_enabled boolean not null default false,
  photo_sharing_enabled boolean not null default false,
  group_sharing_enabled boolean not null default true,
  instant_sos_enabled boolean not null default false,
  updated_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  trip_id uuid references public.trips(id) on delete cascade,
  title text not null,
  body text not null,
  type text not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists trips_owner_id_idx on public.trips(owner_id);
create index if not exists trip_members_user_id_idx on public.trip_members(user_id);
create index if not exists places_location_idx on public.places using gist(location);
create index if not exists reviews_place_id_idx on public.reviews(place_id);
create index if not exists recommendations_user_trip_idx on public.recommendations(user_id, trip_id);
create index if not exists itinerary_days_trip_id_idx on public.itinerary_days(trip_id);
create index if not exists expenses_trip_user_idx on public.expenses(trip_id, user_id);
create index if not exists expenses_created_at_idx on public.expenses(created_at desc);
create index if not exists receipts_trip_user_idx on public.receipts(trip_id, user_id);
create index if not exists photos_trip_id_idx on public.photos(trip_id);
create index if not exists timeline_trip_time_idx on public.travel_timeline(trip_id, event_time);
create index if not exists alerts_trip_valid_idx on public.alerts(trip_id, valid_from);
create index if not exists safety_events_user_created_idx on public.safety_events(user_id, created_at desc);

create or replace function public.set_updated_at() returns trigger language plpgsql security invoker as $$
begin new.updated_at = now(); return new; end; $$;
create trigger profiles_updated_at before update on public.profiles for each row execute procedure public.set_updated_at();
create trigger trips_updated_at before update on public.trips for each row execute procedure public.set_updated_at();
create trigger preferences_updated_at before update on public.user_preferences for each row execute procedure public.set_updated_at();

create or replace function public.handle_new_auth_user() returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.users(id) values (new.id) on conflict do nothing;
  insert into public.profiles(user_id, name) values (new.id, coalesce(new.raw_user_meta_data->>'name', '')) on conflict (user_id) do nothing;
  insert into public.user_preferences(user_id) values (new.id) on conflict (user_id) do nothing;
  return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_auth_user();

create or replace function public.is_trip_member(target_trip uuid) returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.trips t where t.id = target_trip and t.owner_id = auth.uid())
      or exists (select 1 from public.trip_members m where m.trip_id = target_trip and m.user_id = auth.uid());
$$;

alter table public.users enable row level security;
alter table public.profiles enable row level security;
alter table public.destinations enable row level security;
alter table public.trips enable row level security;
alter table public.trip_members enable row level security;
alter table public.places enable row level security;
alter table public.accommodations enable row level security;
alter table public.restaurants enable row level security;
alter table public.reviews enable row level security;
alter table public.recommendations enable row level security;
alter table public.itinerary_days enable row level security;
alter table public.itinerary_items enable row level security;
alter table public.receipts enable row level security;
alter table public.expense_categories enable row level security;
alter table public.expenses enable row level security;
alter table public.photos enable row level security;
alter table public.photo_metadata enable row level security;
alter table public.travel_timeline enable row level security;
alter table public.magazines enable row level security;
alter table public.magazine_pages enable row level security;
alter table public.danger_zones enable row level security;
alter table public.safety_events enable row level security;
alter table public.emergency_contacts enable row level security;
alter table public.alerts enable row level security;
alter table public.saved_offline_regions enable row level security;
alter table public.user_preferences enable row level security;
alter table public.notifications enable row level security;

create policy "own user row" on public.users for select using (id = auth.uid());
create policy "own profile" on public.profiles for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "read destinations" on public.destinations for select to authenticated using (true);
create policy "trip members read trips" on public.trips for select using (public.is_trip_member(id));
create policy "owners create trips" on public.trips for insert with check (owner_id = auth.uid());
create policy "owners update trips" on public.trips for update using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "owners delete trips" on public.trips for delete using (owner_id = auth.uid());
create policy "members read membership" on public.trip_members for select using (public.is_trip_member(trip_id));
create policy "owners manage members" on public.trip_members for all using (exists (select 1 from public.trips where id = trip_id and owner_id = auth.uid())) with check (exists (select 1 from public.trips where id = trip_id and owner_id = auth.uid()));
create policy "read places" on public.places for select to authenticated using (true);
create policy "read accommodations" on public.accommodations for select to authenticated using (true);
create policy "read restaurants" on public.restaurants for select to authenticated using (true);
create policy "read permitted reviews" on public.reviews for select to authenticated using (true);
create policy "own recommendations" on public.recommendations for select using (user_id = auth.uid());
create policy "trip itinerary access" on public.itinerary_days for all using (public.is_trip_member(trip_id)) with check (public.is_trip_member(trip_id));
create policy "item via permitted day" on public.itinerary_items for all using (exists (select 1 from public.itinerary_days d where d.id = itinerary_day_id and public.is_trip_member(d.trip_id))) with check (exists (select 1 from public.itinerary_days d where d.id = itinerary_day_id and public.is_trip_member(d.trip_id)));
create policy "own receipts" on public.receipts for all using (user_id = auth.uid()) with check (user_id = auth.uid() and public.is_trip_member(trip_id));
create policy "read categories" on public.expense_categories for select to authenticated using (true);
create policy "own expenses" on public.expenses for all using (user_id = auth.uid()) with check (user_id = auth.uid() and public.is_trip_member(trip_id));
create policy "trip members read photos" on public.photos for select using (public.is_trip_member(trip_id));
create policy "members upload own photos" on public.photos for insert with check (user_id = auth.uid() and public.is_trip_member(trip_id));
create policy "owners modify own photos" on public.photos for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "owners delete own photos" on public.photos for delete using (user_id = auth.uid());
create policy "metadata follows photo access" on public.photo_metadata for all using (exists (select 1 from public.photos p where p.id = photo_id and public.is_trip_member(p.trip_id))) with check (exists (select 1 from public.photos p where p.id = photo_id and public.is_trip_member(p.trip_id)));
create policy "timeline follows trip access" on public.travel_timeline for all using (public.is_trip_member(trip_id)) with check (public.is_trip_member(trip_id));
create policy "magazines follow trip access" on public.magazines for all using (public.is_trip_member(trip_id)) with check (public.is_trip_member(trip_id));
create policy "pages follow magazine access" on public.magazine_pages for all using (exists (select 1 from public.magazines m where m.id = magazine_id and public.is_trip_member(m.trip_id))) with check (exists (select 1 from public.magazines m where m.id = magazine_id and public.is_trip_member(m.trip_id)));
create policy "read active zones" on public.danger_zones for select to authenticated using (active);
create policy "own safety events" on public.safety_events for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own emergency contacts" on public.emergency_contacts for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "member alerts" on public.alerts for select using (trip_id is null or public.is_trip_member(trip_id));
create policy "own offline regions" on public.saved_offline_regions for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own preferences" on public.user_preferences for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own notifications" on public.notifications for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- All objects are private. The client uses its own authenticated JWT; never service_role.
insert into storage.buckets (id, name, public) values ('trip-photos', 'trip-photos', false), ('receipts', 'receipts', false), ('magazine-assets', 'magazine-assets', false) on conflict (id) do update set public = false;
create policy "trip photos readable by member" on storage.objects for select to authenticated using (bucket_id = 'trip-photos' and public.is_trip_member((storage.foldername(name))[1]::uuid));
create policy "trip photo upload by member" on storage.objects for insert to authenticated with check (bucket_id = 'trip-photos' and public.is_trip_member((storage.foldername(name))[1]::uuid));
create policy "trip photo delete by uploader" on storage.objects for delete to authenticated using (bucket_id = 'trip-photos' and owner_id = auth.uid());
create policy "own receipt access" on storage.objects for all to authenticated using (bucket_id = 'receipts' and (storage.foldername(name))[1] = auth.uid()::text) with check (bucket_id = 'receipts' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "magazine assets by member" on storage.objects for select to authenticated using (bucket_id = 'magazine-assets' and public.is_trip_member((storage.foldername(name))[1]::uuid));
