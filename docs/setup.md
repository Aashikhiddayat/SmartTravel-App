# Local development

## Backend (Windows PowerShell)

```powershell
Copy-Item .env.example backend/.env
py -3.13 -m venv backend/.venv
backend/.venv/Scripts/python -m pip install -r backend/requirements.txt
backend/.venv/Scripts/python -m uvicorn app.main:app --app-dir backend --reload
```

Check [http://localhost:8000/health](http://localhost:8000/health) and [http://localhost:8000/docs](http://localhost:8000/docs). `DEMO_MODE=true` and `MOCK_AI=true` require no account or API key.

## Flutter

Install Flutter stable and Android Studio, then create native platform folders if this source-only skeleton is being initialized on a new machine:

```powershell
cd mobile
flutter create --platforms=android,ios,web .
flutter pub get
flutter run --dart-define=DEMO_MODE=true --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Use `http://localhost:8000` for web/Windows and `10.0.2.2` for the Android emulator. A physical phone uses the workstation's LAN IP over a trusted development network.

## Real mode

Set `DEMO_MODE=false` in the backend and pass only `SUPABASE_URL` and `SUPABASE_ANON_KEY` to Flutter. Put all server-only settings in `backend/.env`. Add approved maps/Places/alert/FCM/OpenAI adapters only after their official configuration and terms are complete.
