from app.repositories.demo_store import demo_store
from app.schemas.common import Place
from app.services.geo import distance_meters


class RecommendationService:
    """Transparent, deterministic ranking. An LLM never decides factual ranking alone."""

    def nearby(self, latitude: float, longitude: float, category: str | None, limit: int) -> list[dict]:
        ranked: list[dict] = []
        for place in demo_store.places:
            if category and place.category != category:
                continue
            distance = distance_meters(latitude, longitude, place.latitude, place.longitude)
            rating_score = place.rating / 5 * 35
            distance_score = max(0, 30 - distance / 300)
            budget_score = (5 - place.price_level) / 4 * 15
            preference_score = 15 if category in {"food", "attraction"} else 10
            safety_score = 5
            final_score = round(rating_score + distance_score + budget_score + preference_score + safety_score, 1)
            ranked.append({
                "place": place, "score": final_score, "distance_meters": round(distance),
                "reason": "Ranked from rating, distance, price level, category fit and demo safety data.",
                "pros": [f"{place.rating:.1f} demo rating", "Close to your selected map point"],
                "cons": ["Demo/provider data — verify hours, availability and price"],
                "estimated_cost": [200, 500, 1000, 2000][place.price_level - 1],
                "safety_level": "demo-unknown",
                "score_breakdown": {"rating": round(rating_score, 1), "distance": round(distance_score, 1), "budget": round(budget_score, 1), "preference": preference_score, "safety": safety_score},
            })
        return sorted(ranked, key=lambda result: result["score"], reverse=True)[:limit]

    def get_place(self, place_id) -> Place | None:
        return next((place for place in demo_store.places if place.id == place_id), None)


class ReviewAnalysisService:
    def analyze(self, place: Place) -> dict:
        # In real mode this operates only on permitted, minimal review fields from the official provider.
        return {
            "place_id": place.id, "overall_sentiment": "positive", "rating": place.rating,
            "pros": ["Convenient location in the demo listing", "Strong demo rating"],
            "cons": ["Review details are demo data", "Confirm availability and current conditions"],
            "dimensions": {"cleanliness": "positive", "location": "positive", "staff": "not enough permitted data", "food": "not enough permitted data", "value": "mixed", "safety": "not assessed from reviews"},
            "why_recommended": "It has a strong demo rating and fits the selected category.",
            "potential_concerns": "Do not treat this summary as a live provider review analysis.",
            "is_demo": True,
        }

