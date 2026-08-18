import logging
import time
from uuid import uuid4

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.config import get_settings
from app.routers import alerts, assistant, auth, emergency, expenses, memories, places, recommendations, safety, trips

settings = get_settings()
logging.basicConfig(level=settings.log_level, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger("smart_trip")

app = FastAPI(title="SMART TRIP API", version="0.1.0", description="Safety-aware AI travel companion API. Demo data is explicitly labelled.")
app.add_middleware(CORSMiddleware, allow_origins=settings.cors_origins, allow_credentials=True, allow_methods=["*"], allow_headers=["*"])


@app.middleware("http")
async def request_logging(request: Request, call_next):
    request_id = request.headers.get("X-Request-ID", str(uuid4()))
    started = time.perf_counter()
    try:
        response = await call_next(request)
    except Exception:
        logger.exception("request_failed request_id=%s path=%s", request_id, request.url.path)
        return JSONResponse(status_code=500, content={"detail": "Unexpected server error", "request_id": request_id})
    response.headers["X-Request-ID"] = request_id
    logger.info("request_complete request_id=%s method=%s path=%s status=%s latency_ms=%d", request_id, request.method, request.url.path, response.status_code, (time.perf_counter() - started) * 1000)
    return response


@app.get("/health", tags=["system"])
def health():
    return {"status": "ok", "mode": "demo" if settings.demo_mode else "production", "mock_ai": settings.mock_ai}


app.include_router(auth.router)
app.include_router(trips.router)
app.include_router(places.router)
app.include_router(recommendations.router)
app.include_router(expenses.router)
app.include_router(safety.router)
app.include_router(alerts.router)
app.include_router(memories.router)
app.include_router(assistant.router)
app.include_router(emergency.router)
