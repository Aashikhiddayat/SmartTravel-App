"""Thread-safe seed repository used only in demo/test mode.

Production repositories are intentionally kept behind service interfaces so they can
use Supabase/Postgres without changing API or mobile code.
"""
from __future__ import annotations

from datetime import datetime, timedelta, timezone
from threading import RLock
from uuid import UUID, uuid4

from app.schemas.common import Alert, DangerZone, Expense, Place, Trip


MUNNAR_LATITUDE = 10.0889
MUNNAR_LONGITUDE = 77.0595


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class DemoStore:
    def __init__(self) -> None:
        self._lock = RLock()
        self.places = self._seed_places()
        self.zones = self._seed_zones()
        self.trips: dict[UUID, Trip] = {}
        self.members: dict[UUID, dict[str, str]] = {}
        self.expenses: list[Expense] = []
        self.itineraries: dict[UUID, list[dict]] = {}
        self.profiles: dict[str, dict] = {}
        self.alerts = self._seed_alerts()

    @staticmethod
    def _seed_places() -> list[Place]:
        records = [
            ("Tea Garden Walk", "attraction", "A calm guided walk among Munnar tea estates.", 10.0863, 77.0600, 4.6, 1, "Munnar, Kerala"),
            ("Eravikulam National Park", "attraction", "Protected highland park; check official opening status before travel.", 10.1390, 77.0620, 4.7, 2, "Rajamalai, Munnar"),
            ("Mattupetty Dam", "attraction", "Scenic reservoir and viewpoint.", 10.1035, 77.1220, 4.4, 1, "Mattupetty, Kerala"),
            ("Saravana Bhavan Munnar", "food", "Demo vegetarian-friendly South Indian restaurant listing.", 10.0898, 77.0590, 4.3, 1, "Main Bazaar, Munnar"),
            ("Tea Tales Cafe", "food", "Demo cafe with vegetarian options.", 10.0915, 77.0584, 4.4, 2, "Munnar Town, Kerala"),
            ("Cloudscape Homestay", "stay", "Demo budget-friendly homestay listing.", 10.0940, 77.0530, 4.5, 2, "Munnar, Kerala"),
            ("Highrange Retreat", "stay", "Demo stay close to the town centre.", 10.0840, 77.0558, 4.2, 3, "Munnar, Kerala"),
            ("Munnar Community Health Centre", "essential", "Demo essential-service point; verify current details before emergency use.", 10.0905, 77.0618, 4.0, 1, "Munnar, Kerala"),
            ("Munnar Police Station", "essential", "Demo essential-service point; verify current details before emergency use.", 10.0871, 77.0565, 4.0, 1, "Munnar, Kerala"),
        ]
        return [
            Place(
                id=uuid4(), name=name, category=category, description=description,
                latitude=lat, longitude=lng, rating=rating, price_level=price,
                address=address, opening_hours="Verify with provider", source="SMART TRIP demo seed",
            )
            for name, category, description, lat, lng, rating, price, address in records
        ]

    @staticmethod
    def _seed_zones() -> list[DangerZone]:
        from app.schemas.common import DemoDisclosure
        return [
            DangerZone(id=uuid4(), name="Demo landslide caution area", description="Demonstration-only zone for the SIH safety flow. Not an official warning.", latitude=10.1110, longitude=77.0970, radius_meters=600, risk_level="caution", source="SMART TRIP demo seed", disclosure=DemoDisclosure()),
            DangerZone(id=uuid4(), name="Demo restricted-risk area", description="Demonstration-only high-risk zone. Do not rely on it for real-world safety decisions.", latitude=10.1185, longitude=77.1025, radius_meters=350, risk_level="high", source="SMART TRIP demo seed", disclosure=DemoDisclosure()),
        ]

    @staticmethod
    def _seed_alerts() -> list[Alert]:
        now = utc_now()
        return [
            Alert(id=uuid4(), trip_id=None, alert_type="weather", title="DEMO: heavy-rain disruption", message="Demo alert for re-planning: move outdoor activities to an indoor option. Verify live weather with an approved provider.", severity="caution", source="SMART TRIP demo seed", valid_from=now, valid_until=now + timedelta(hours=12)),
        ]

    def create_trip(self, owner_id: str, values: dict) -> Trip:
        with self._lock:
            trip = Trip(id=uuid4(), owner_id=owner_id, created_at=utc_now(), status="upcoming", **values)
            self.trips[trip.id] = trip
            self.members[trip.id] = {owner_id: "owner"}
            return trip

    def list_trips(self, owner_id: str) -> list[Trip]:
        with self._lock:
            return [trip for trip in self.trips.values() if owner_id in self.members.get(trip.id, {})]

    def get_trip(self, trip_id: UUID, owner_id: str) -> Trip | None:
        with self._lock:
            trip = self.trips.get(trip_id)
            return trip if trip and owner_id in self.members.get(trip.id, {}) else None

    def is_owner(self, trip_id: UUID, user_id: str) -> bool:
        with self._lock:
            return self.members.get(trip_id, {}).get(user_id) == "owner"

    def add_member(self, trip_id: UUID, user_id: str, role: str) -> None:
        with self._lock:
            self.members.setdefault(trip_id, {})[user_id] = role

    def list_members(self, trip_id: UUID) -> list[dict]:
        with self._lock:
            return [{"user_id": user_id, "role": role} for user_id, role in self.members.get(trip_id, {}).items()]

    def save_itinerary(self, trip_id: UUID, days: list[dict]) -> None:
        with self._lock:
            self.itineraries[trip_id] = days

    def get_itinerary(self, trip_id: UUID) -> list[dict]:
        with self._lock:
            return self.itineraries.get(trip_id, [])

    def add_expense(self, expense: Expense) -> Expense:
        with self._lock:
            self.expenses.append(expense)
        return expense

    def list_expenses(self, trip_id: UUID, user_id: str) -> list[Expense]:
        with self._lock:
            return [item for item in self.expenses if item.trip_id == trip_id and item.user_id == user_id]

    def list_trip_expenses(self, trip_id: UUID) -> list[Expense]:
        with self._lock:
            return [item for item in self.expenses if item.trip_id == trip_id]


demo_store = DemoStore()
