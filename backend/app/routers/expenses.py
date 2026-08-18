from fastapi import APIRouter, status
from uuid import UUID

from app.dependencies import CurrentUser
from app.repositories.demo_store import demo_store
from app.routers.trips import require_trip
from app.schemas.requests import ExpenseCreate, ReceiptScanRequest
from app.services.expenses import ExpenseService

router = APIRouter(prefix="/expenses", tags=["expenses"])
service = ExpenseService()


@router.post("", status_code=status.HTTP_201_CREATED)
def add_expense(trip_id: UUID, payload: ExpenseCreate, user_id: CurrentUser):
    require_trip(trip_id, user_id)
    expense = demo_store.add_expense(service.create(trip_id, user_id, payload))
    return {"expense": expense, "is_demo": True}


@router.get("/summary")
def expense_summary(trip_id: UUID, user_id: CurrentUser):
    trip = require_trip(trip_id, user_id)
    expenses = demo_store.list_expenses(trip_id, user_id)
    return {"expenses": expenses, "summary": service.summary(expenses, trip.budget), "is_demo": True}


@router.post("/receipt-scan")
def scan_receipt(payload: ReceiptScanRequest, user_id: CurrentUser):
    require_trip(payload.trip_id, user_id)
    return {"draft": service.parse_receipt(payload.ocr_text), "is_demo": True, "next_step": "User must confirm/edit this draft, then call POST /expenses."}
