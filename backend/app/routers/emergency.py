from fastapi import APIRouter

from app.dependencies import CurrentUser
from app.routers.trips import require_trip
from app.schemas.requests import SOSRequest

router = APIRouter(prefix="/emergency", tags=["emergency"])


@router.post("/sos")
def sos(payload: SOSRequest, user_id: CurrentUser):
    trip_title = None
    if payload.trip_id:
        trip_title = require_trip(payload.trip_id, user_id).title
    message = f"Emergency. I may need assistance. Current location: {payload.latitude:.5f}, {payload.longitude:.5f}."
    if trip_title:
        message += f" Trip: {trip_title}."
    return {
        "message": message,
        "share_location": payload.share_location,
        "nearby_services": [],
        "emergency_numbers": [],
        "notice": "No emergency number is supplied in demo mode. Configure a verified country/destination provider before production use.",
        "is_demo": True,
    }

