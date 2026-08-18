from datetime import datetime, timezone
from uuid import uuid4


class PhotoAIService:
    def analyze(self, storage_path: str, latitude: float | None, longitude: float | None) -> dict:
        # Production vision calls must not claim exact recognition below configured confidence.
        return {"storage_path": storage_path, "caption": "A travel memory from your trip.", "ai_tags": ["travel", "memory"], "detected_category": "unknown", "detected_place": None, "confidence": 0.35, "requires_user_review": True, "coordinates_received": latitude is not None and longitude is not None, "is_demo": True}


class MagazineService:
    def generate(self, trip, expenses, itinerary) -> dict:
        total = sum(item.amount for item in expenses)
        return {"id": uuid4(), "trip_id": trip.id, "title": f"My {trip.destination} Journey", "subtitle": f"{trip.title} — a SMART TRIP demo magazine", "status": "ready", "generated_at": datetime.now(timezone.utc), "pages": [
            {"page_number": 1, "page_type": "cover", "title": f"My {trip.destination} Journey", "content": "A travel story generated from your saved trip data."},
            {"page_number": 2, "page_type": "overview", "title": "Trip overview", "content": f"{len(itinerary)} days planned • {len(expenses)} expenses • {trip.currency} {total:,.0f} recorded."},
            {"page_number": 3, "page_type": "highlights", "title": "Highlights", "content": "Your itinerary, photos, and expenses become editable memories here."},
        ], "is_demo": True}


class TravelAssistantService:
    def respond(self, message: str, budget_remaining: float) -> dict:
        lower = message.lower()
        if "budget" in lower or "spend" in lower:
            answer = f"Your demo trip has about INR {budget_remaining:,.0f} remaining based on recorded expenses."
        elif "late" in lower or "replan" in lower:
            answer = "I can replan around a delay: keep the next confirmed meal, replace an outdoor stop with a flexible indoor/rest buffer, and verify current travel conditions."
        elif "food" in lower or "eat" in lower or "vegetarian" in lower:
            answer = "Try the Food tab for ranked nearby demo options. Before visiting, verify dietary suitability, hours, price, and availability with the venue."
        elif "safe" in lower:
            answer = "Use the Safety tab to run a location or route check. Demo zones are instructional only and cannot prove that an area is safe."
        else:
            answer = "I use your current trip, itinerary, budget and approved providers. In demo mode, answers are illustrative and must not be treated as live travel guidance."
        return {"answer": answer, "tools_used": ["trip_context", "expense_summary"], "is_demo": True}

