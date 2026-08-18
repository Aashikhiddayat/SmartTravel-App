from fastapi import APIRouter, HTTPException
from uuid import UUID

from app.dependencies import CurrentUser
from app.repositories.demo_store import demo_store
from app.routers.trips import require_trip
from app.schemas.requests import PhotoAnalyzeRequest
from app.services.memories import MagazineService, PhotoAIService

router = APIRouter(tags=["memories"])


@router.post("/photos/analyze")
def analyze_photo(payload: PhotoAnalyzeRequest, user_id: CurrentUser):
    require_trip(payload.trip_id, user_id)
    return PhotoAIService().analyze(payload.storage_path, payload.latitude, payload.longitude)


@router.post("/magazines/generate")
def generate_magazine(trip_id: UUID, user_id: CurrentUser):
    trip = require_trip(trip_id, user_id)
    magazine = MagazineService().generate(trip, demo_store.list_expenses(trip_id, user_id), demo_store.get_itinerary(trip_id))
    return {"magazine": magazine, "is_demo": True}


@router.get("/magazines/{magazine_id}")
def get_magazine(magazine_id: UUID, _: CurrentUser = None):
    raise HTTPException(status_code=404, detail="Demo magazines are generated in-session; configure Postgres storage for persistence.")

