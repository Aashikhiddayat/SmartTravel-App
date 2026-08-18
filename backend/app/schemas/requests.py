from datetime import date
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, Field, field_validator


class ProfileUpsert(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    preferred_language: str = Field(default="en", max_length=10)
    budget_preference: str = Field(default="Balanced", max_length=30)
    travel_style: str = Field(default="Balanced", max_length=30)
    food_preferences: list[str] = Field(default_factory=list, max_length=10)
    interests: list[str] = Field(default_factory=list, max_length=15)


class TripCreate(BaseModel):
    title: str = Field(min_length=2, max_length=120)
    destination: str = Field(min_length=2, max_length=120)
    start_date: date
    end_date: date
    budget: float = Field(gt=0, le=10_000_000)
    currency: str = Field(default="INR", min_length=3, max_length=3)

    @field_validator("end_date")
    @classmethod
    def end_after_start(cls, value: date, info):
        if "start_date" in info.data and value < info.data["start_date"]:
            raise ValueError("end_date must be on or after start_date")
        return value


class TripMemberAdd(BaseModel):
    """Demo-only direct invite. Production should resolve a verified invitation, never a raw client supplied ID."""

    user_id: str = Field(min_length=3, max_length=100)
    role: Literal["editor", "member"] = "member"


class PlanRequest(BaseModel):
    travellers: int = Field(default=1, ge=1, le=20)
    travel_style: str = Field(default="Balanced", max_length=30)
    interests: list[str] = Field(default_factory=list, max_length=15)
    food_preferences: list[str] = Field(default_factory=list, max_length=10)
    accommodation_preference: str = Field(default="Comfortable", max_length=50)
    preferred_pace: Literal["relaxed", "balanced", "fast"] = "balanced"


class ReplanRequest(PlanRequest):
    trigger: Literal["weather", "place_closure", "route_problem", "danger_alert", "behind_schedule", "budget_change", "skip"]
    detail: str = Field(min_length=3, max_length=500)


class NearbyQuery(BaseModel):
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    category: Literal["food", "stay", "attraction", "essential"] | None = None
    limit: int = Field(default=10, ge=1, le=30)


class ExpenseCreate(BaseModel):
    category: Literal["Transport", "Accommodation", "Food", "Tickets", "Shopping", "Emergency", "Other"]
    amount: float = Field(gt=0, le=1_000_000)
    currency: str = Field(default="INR", min_length=3, max_length=3)
    description: str = Field(min_length=1, max_length=300)
    merchant: str | None = Field(default=None, max_length=120)
    expense_date: date


class ReceiptScanRequest(BaseModel):
    # Production sends an authenticated object-storage path after a client-side/on-device scan.
    ocr_text: str = Field(min_length=1, max_length=8000)
    trip_id: UUID


class LocationCheck(BaseModel):
    trip_id: UUID | None = None
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)


class RouteCheck(BaseModel):
    points: list[tuple[float, float]] = Field(min_length=2, max_length=500)


class PhotoAnalyzeRequest(BaseModel):
    trip_id: UUID
    storage_path: str = Field(min_length=1, max_length=500)
    captured_at: str
    latitude: float | None = None
    longitude: float | None = None


class AssistantRequest(BaseModel):
    trip_id: UUID
    message: str = Field(min_length=1, max_length=1000)


class SOSRequest(BaseModel):
    trip_id: UUID | None = None
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    share_location: bool = True
