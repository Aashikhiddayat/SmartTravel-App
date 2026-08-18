from fastapi import APIRouter
from uuid import UUID

from app.dependencies import CurrentUser
from app.repositories.demo_store import demo_store
from app.routers.trips import require_trip

router = APIRouter(prefix="/alerts", tags=["alerts"])


@router.get("")
def list_alerts(trip_id: UUID | None = None, user_id: CurrentUser = None):
    if trip_id:
        require_trip(trip_id, user_id)
    return {"alerts": demo_store.alerts, "is_demo": True, "data_notice": "These alerts are DEMO only; do not treat them as current travel guidance."}


@router.post("/recheck")
def recheck_alerts(trip_id: UUID, user_id: CurrentUser):
    require_trip(trip_id, user_id)
    return {"alerts": demo_store.alerts, "provider_status": "demo provider", "checked_at": "demo", "is_demo": True}

