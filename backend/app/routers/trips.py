from fastapi import APIRouter, HTTPException, status
from uuid import UUID

from app.dependencies import CurrentUser
from app.repositories.demo_store import demo_store
from app.schemas.requests import PlanRequest, ReplanRequest, TripCreate, TripMemberAdd
from app.services.planning import ReplanningService, TripPlanningService

router = APIRouter(prefix="/trips", tags=["trips"])


def require_trip(trip_id: UUID, user_id: str):
    trip = demo_store.get_trip(trip_id, user_id)
    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
    return trip


@router.post("", status_code=status.HTTP_201_CREATED)
def create_trip(payload: TripCreate, user_id: CurrentUser):
    trip = demo_store.create_trip(user_id, payload.model_dump())
    return {"trip": trip, "is_demo": True}


@router.get("")
def list_trips(user_id: CurrentUser):
    return {"trips": demo_store.list_trips(user_id), "is_demo": True}


@router.get("/{trip_id}")
def get_trip(trip_id: UUID, user_id: CurrentUser):
    trip = require_trip(trip_id, user_id)
    return {"trip": trip, "itinerary": demo_store.get_itinerary(trip_id), "is_demo": True}


@router.get("/{trip_id}/members")
def list_members(trip_id: UUID, user_id: CurrentUser):
    require_trip(trip_id, user_id)
    return {"members": demo_store.list_members(trip_id), "is_demo": True}


@router.post("/{trip_id}/members", status_code=status.HTTP_201_CREATED)
def add_member(trip_id: UUID, payload: TripMemberAdd, user_id: CurrentUser):
    require_trip(trip_id, user_id)
    if not demo_store.is_owner(trip_id, user_id):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only the trip owner can invite members")
    demo_store.add_member(trip_id, payload.user_id, payload.role)
    return {"members": demo_store.list_members(trip_id), "is_demo": True, "notice": "Demo direct invite only. Production must use a verified invitation flow."}


@router.get("/{trip_id}/settlements")
def settlements(trip_id: UUID, user_id: CurrentUser):
    require_trip(trip_id, user_id)
    members = demo_store.list_members(trip_id)
    expenses = demo_store.list_trip_expenses(trip_id)
    paid = {member["user_id"]: 0.0 for member in members}
    for expense in expenses:
        paid[expense.user_id] = paid.get(expense.user_id, 0.0) + expense.amount
    total = sum(paid.values())
    share = total / len(members) if members else 0
    return {"total": round(total, 2), "fair_share": round(share, 2), "balances": [{"user_id": member, "paid": round(amount, 2), "balance": round(amount - share, 2)} for member, amount in paid.items()], "is_demo": True}


@router.post("/{trip_id}/plan")
def plan_trip(trip_id: UUID, payload: PlanRequest, user_id: CurrentUser):
    trip = require_trip(trip_id, user_id)
    itinerary = TripPlanningService().generate(trip, payload)
    serialized = [day.model_dump(mode="json") for day in itinerary]
    demo_store.save_itinerary(trip_id, serialized)
    return {"trip_id": trip_id, "itinerary": itinerary, "is_demo": True, "data_notice": "Plans use seeded places in demo mode; confirm all live facts before travel."}


@router.post("/{trip_id}/replan")
def replan_trip(trip_id: UUID, payload: ReplanRequest, user_id: CurrentUser):
    trip = require_trip(trip_id, user_id)
    itinerary = ReplanningService().replan(trip, payload)
    serialized = [day.model_dump(mode="json") for day in itinerary]
    demo_store.save_itinerary(trip_id, serialized)
    return {"trip_id": trip_id, "itinerary": itinerary, "trigger": payload.trigger, "is_demo": True}
