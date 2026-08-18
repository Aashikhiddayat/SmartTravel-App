from datetime import date, datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class APIModel(BaseModel):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)


class DemoDisclosure(APIModel):
    is_demo: bool = True
    label: str = "DEMO DATA — not live or official"


class Place(APIModel):
    id: UUID
    name: str
    category: Literal["food", "stay", "attraction", "essential"]
    description: str
    latitude: float
    longitude: float
    rating: float = Field(ge=0, le=5)
    price_level: int = Field(ge=1, le=4)
    address: str
    source: str = "demo"
    opening_hours: str | None = None


class Trip(APIModel):
    id: UUID
    owner_id: str
    title: str
    destination: str
    start_date: date
    end_date: date
    budget: float
    currency: str = "INR"
    status: Literal["upcoming", "active", "completed"] = "upcoming"
    created_at: datetime


class ItineraryItem(APIModel):
    id: UUID
    day_number: int
    start_time: str
    end_time: str
    title: str
    category: str
    place_id: UUID | None = None
    estimated_cost: float = 0
    notes: str
    ai_reason: str


class ItineraryDay(APIModel):
    day_number: int
    date: date
    summary: str
    items: list[ItineraryItem]


class Expense(APIModel):
    id: UUID
    trip_id: UUID
    user_id: str
    category: Literal["Transport", "Accommodation", "Food", "Tickets", "Shopping", "Emergency", "Other"]
    amount: float = Field(gt=0)
    currency: str = "INR"
    description: str
    merchant: str | None = None
    expense_date: date
    created_at: datetime


class Alert(APIModel):
    id: UUID
    trip_id: UUID | None = None
    alert_type: Literal["weather", "flood", "storm", "heat", "road_closure", "transport", "safety", "place_closure"]
    title: str
    message: str
    severity: Literal["info", "caution", "danger"]
    source: str
    valid_from: datetime
    valid_until: datetime | None = None
    disclosure: DemoDisclosure | None = None


class DangerZone(APIModel):
    id: UUID
    name: str
    description: str
    latitude: float
    longitude: float
    radius_meters: float
    risk_level: Literal["caution", "high"]
    source: str
    source_url: str | None = None
    active: bool = True
    disclosure: DemoDisclosure

