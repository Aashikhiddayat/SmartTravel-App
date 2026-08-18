# Deployment

## Backend

Render reads `render.yaml` and the backend `Dockerfile`. Create a web service, add `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` (server only), `OPENAI_API_KEY` (server only), approved provider keys and allowed CORS origins. Set `DEMO_MODE=false` and `MOCK_AI=false` for real use. The health probe is `GET /health`.

Railway is an alternative: create a service from `backend/`, build with the Dockerfile, configure the same variables, and use `uvicorn app.main:app --host 0.0.0.0 --port $PORT` if overriding the Docker command.

Free tiers have uptime, quota, suspension and billing limitations. Do not promise production SLA or backups on free plans.

## Mobile

```powershell
cd mobile
flutter pub get
flutter test
flutter analyze
flutter build apk --release --dart-define=DEMO_MODE=false --dart-define=API_BASE_URL=https://your-api.example --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Create/upload Android signing configuration before a release. Google Play developer registration and store distribution can have fees and policy requirements; they are not represented as free by this project.

## CI

GitHub Actions runs backend lint/tests/Docker build and Flutter analyze/tests on each push. It does not deploy automatically and therefore requires no deployment secret until you deliberately add an environment-protected deploy job.

