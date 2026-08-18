from fastapi import APIRouter

from app.dependencies import CurrentUser
from app.repositories.demo_store import demo_store
from app.routers.trips import require_trip
from app.schemas.requests import AssistantRequest
from app.services.expenses import ExpenseService
from app.services.memories import TravelAssistantService

router = APIRouter(prefix="/assistant", tags=["assistant"])


@router.post("/chat")
def chat(payload: AssistantRequest, user_id: CurrentUser):
    trip = require_trip(payload.trip_id, user_id)
    summary = ExpenseService().summary(demo_store.list_expenses(trip.id, user_id), trip.budget)
    return TravelAssistantService().respond(payload.message, summary["remaining_budget"])

