import re
from collections import defaultdict
from datetime import date, datetime, timezone
from uuid import UUID, uuid4

from app.schemas.common import Expense
from app.schemas.requests import ExpenseCreate


class ExpenseService:
    def create(self, trip_id: UUID, user_id: str, request: ExpenseCreate) -> Expense:
        return Expense(id=uuid4(), trip_id=trip_id, user_id=user_id, created_at=datetime.now(timezone.utc), **request.model_dump())

    def summary(self, expenses: list[Expense], budget: float) -> dict:
        total = round(sum(expense.amount for expense in expenses), 2)
        breakdown: dict[str, float] = defaultdict(float)
        for expense in expenses:
            breakdown[expense.category] += expense.amount
        days = max((date.today() - min((item.expense_date for item in expenses), default=date.today())).days + 1, 1)
        daily_average = total / days
        return {"total_spent": total, "remaining_budget": round(budget - total, 2), "budget_percentage": round(total / budget * 100, 1) if budget else 0, "daily_average": round(daily_average, 2), "forecast_total": round(daily_average * max(days, 5), 2), "by_category": dict(breakdown)}

    def parse_receipt(self, ocr_text: str) -> dict:
        # Intentionally returns a draft requiring explicit user confirmation.
        currency = "INR" if any(mark in ocr_text.lower() for mark in ("₹", "inr", "rs")) else "UNKNOWN"
        numbers = re.findall(r"(?:₹|rs\.?|inr)?\s*(\d{1,6}(?:\.\d{1,2})?)", ocr_text, flags=re.IGNORECASE)
        amount = max((float(value) for value in numbers), default=None)
        merchant = next((line.strip() for line in ocr_text.splitlines() if len(line.strip()) > 3), "Unknown merchant")
        return {"merchant": merchant[:120], "total_amount": amount, "currency": currency, "confidence": 0.62 if amount else 0.2, "requires_confirmation": True, "message": "Please verify the detected amount before saving."}

