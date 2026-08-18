# API

All non-health endpoints accept `Authorization: Bearer <Supabase access token>`. When `DEMO_MODE=true`, the API accepts `Bearer demo-user` (or `X-Demo-User`) strictly for local demo/test use.

| Endpoint | Purpose |
| --- | --- |
| `POST /auth/profile` | Save onboarding preferences |
| `POST /trips`, `GET /trips`, `GET /trips/{id}` | Manage private trips |
| `POST /trips/{id}/plan`, `/replan` | Validated AI/demo itinerary operations |
| `GET/POST /trips/{id}/members`, `GET /trips/{id}/settlements` | Group view, demo invite and expense-split calculation |
| `GET /places/nearby`, `GET /places/{id}` | Provider-backed place data |
| `GET /recommendations` | Transparent current-context recommendation ranking |
| `POST /places/{id}/analyze-reviews` | Permitted review summary |
| `POST /expenses`, `GET /expenses/summary` | Private expense tracking |
| `POST /expenses/receipt-scan` | Draft only; the user must confirm before saving |
| `GET /safety/zones`, `POST /safety/check-location`, `/safe-route` | Safety-zone display/geofence/route checks |
| `GET /alerts`, `POST /alerts/recheck` | Alert provider boundary |
| `POST /photos/analyze`, `POST /magazines/generate` | Memory metadata/magazine operations |
| `POST /assistant/chat` | Current-trip tool-oriented assistant |
| `POST /emergency/sos` | Confirmed SOS message preparation |

Errors use FastAPI validation status codes and a user-safe `detail`; clients should not expose raw stack traces. The interactive OpenAPI contract is at `/docs` when the backend is running.
