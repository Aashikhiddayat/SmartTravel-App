# SMART TRIP

SMART TRIP is a safety-aware, AI-assisted travel companion built as a Flutter + FastAPI monorepo. It has three operating modes:

| Mode | Use |
| --- | --- |
| Demo | No credentials: seeded Munnar data, deterministic AI, demo alerts and clearly labelled demo safety zones. |
| Hybrid | Any configured providers are used; unavailable providers fall back to demo data with a disclosure. |
| Real | Supabase, approved Places/maps/alert providers, and OpenAI are configured. |

The repository deliberately does **not** scrape Google Maps or Google Search, embed backend secrets in Flutter, bulk-download OSM public tiles, or present demo safety information as official live data.

## Included now

- FastAPI API with authenticated demo context, trip planning/replanning, recommendation scoring, review analysis, expenses, receipt-confirmation flow, safety/geofence checks, route checks, alerts, SOS preparation, photo metadata and magazine generation.
- Flutter application with authentication/demo entry, trips, explore, budget, safety, alert, memory/magazine, assistant and privacy/navigation flows. The app stores the current session and trip snapshot for offline use.
- Supabase/Postgres/PostGIS schema, indexes, RLS policies, private storage buckets and demo seed data.
- Docker, Render, GitHub Actions, tests and deployment/setup/security documentation.

## Quick start (Windows)

Prerequisites: Git, Python 3.11+, Flutter 3.22+, Android Studio (for Android), and optionally Docker Desktop.

```powershell
git clone <your-repository-url> smart-trip
cd smart-trip
Copy-Item .env.example backend/.env
py -3.13 -m venv backend/.venv
backend/.venv/Scripts/python -m pip install -r backend/requirements.txt
backend/.venv/Scripts/python -m uvicorn app.main:app --app-dir backend --reload
```

In a second terminal:

```powershell
cd mobile
flutter pub get
flutter run --dart-define=DEMO_MODE=true --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For a desktop/browser target, use `http://localhost:8000`. The demo sign-in uses no password and is marked as demo mode in the UI.

## Verification

```powershell
backend/.venv/Scripts/python -m pytest backend/tests -q
cd mobile; flutter analyze; flutter test
```

## Architecture and production setup

Read [architecture](docs/architecture.md), [setup](docs/setup.md), [database](docs/database.md), [API](docs/api.md), [offline maps](docs/offline-maps.md), [security](docs/security.md), and [deployment](docs/deployment.md). Before a real release, configure Supabase Auth redirect URLs, run the SQL migration in the Supabase SQL editor/CLI, create an approved maps/Places billing account if required, configure FCM, and complete privacy/security review.

## Free-tier boundaries

Supabase and Render/Railway offer limited free tiers that may change and may require a payment method. Google Places/Maps and OpenAI commonly require billing configuration even where credits/free usage exist. The app stays demoable without them; provider interfaces must be configured before claiming live data.

## Privacy and safety

Location is checked only when a user elects to use safety/location functionality. Production photo storage is private and accessed through short-lived signed URLs. Demo danger zones and alerts are visibly labelled `DEMO`; they must never be used as emergency guidance. The SOS flow prepares a message and directs the user to verified, destination-specific emergency data supplied by a configured provider.
