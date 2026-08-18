from fastapi import APIRouter

from app.dependencies import CurrentUser
from app.repositories.demo_store import demo_store
from app.schemas.requests import LocationCheck, RouteCheck
from app.services.safety import SafetyService

router = APIRouter(prefix="/safety", tags=["safety"])
service = SafetyService()


@router.get("/zones")
def safety_zones(_: CurrentUser = None):
    return {"zones": demo_store.zones, "is_demo": True, "data_notice": "Demo safety zones are not official live government or emergency data."}


@router.post("/check-location")
def check_location(payload: LocationCheck, _: CurrentUser = None):
    return service.check_location(payload.latitude, payload.longitude)


@router.post("/safe-route")
def safe_route(payload: RouteCheck, _: CurrentUser = None):
    return service.check_route(payload.points)

