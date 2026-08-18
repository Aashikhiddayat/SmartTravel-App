from datetime import timedelta
from uuid import uuid4

from app.repositories.demo_store import demo_store
from app.schemas.common import ItineraryDay, ItineraryItem, Trip
from app.schemas.requests import PlanRequest, ReplanRequest


class TripPlanningService:
    def generate(self, trip: Trip, request: PlanRequest) -> list[ItineraryDay]:
        attractions = [place for place in demo_store.places if place.category == "attraction"]
        food = [place for place in demo_store.places if place.category == "food"]
        day_count = (trip.end_date - trip.start_date).days + 1
        spending_cap = trip.budget / max(day_count, 1)
        days: list[ItineraryDay] = []
        for index in range(day_count):
            attraction = attractions[index % len(attractions)]
            meal = food[index % len(food)]
            items = [
                ItineraryItem(id=uuid4(), day_number=index + 1, start_time="09:30", end_time="12:00", title=attraction.name, category="attraction", place_id=attraction.id, estimated_cost=250, notes="Confirm opening hours with the official provider before leaving.", ai_reason=f"Matches {', '.join(request.interests[:2]) or 'your preferences'} and keeps travel compact."),
                ItineraryItem(id=uuid4(), day_number=index + 1, start_time="12:30", end_time="13:30", title=meal.name, category="food", place_id=meal.id, estimated_cost=350, notes="Vegetarian suitability is based on demo listing; confirm with venue.", ai_reason="Selected for proximity, rating and food preferences."),
                ItineraryItem(id=uuid4(), day_number=index + 1, start_time="15:00", end_time="16:30", title="Rest / flexible local exploration", category="rest", estimated_cost=0, notes="A buffer for weather, queues and travel delays.", ai_reason="Keeps the day within a realistic pace and daily target."),
            ]
            days.append(ItineraryDay(day_number=index + 1, date=trip.start_date + timedelta(days=index), summary=f"Balanced day with an estimated planned spend below {trip.currency} {spending_cap:,.0f}.", items=items))
        return days


class ReplanningService:
    def replan(self, trip: Trip, request: ReplanRequest) -> list[ItineraryDay]:
        days = TripPlanningService().generate(trip, request)
        for day in days:
            if request.trigger in {"weather", "danger_alert", "route_problem"}:
                day.summary = f"Replanned for {request.trigger.replace('_', ' ')}: outdoor activity is optional; verify current conditions. {request.detail}"
                day.items[-1].title = "Indoor cultural stop / rest buffer"
                day.items[-1].notes = "Demo replan. Use a verified provider before making real safety decisions."
        return days

