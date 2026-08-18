from fastapi import APIRouter, HTTPException
from uuid import UUID

from app.dependencies import CurrentUser
from app.schemas.requests import NearbyQuery
from app.services.recommendations import RecommendationService, ReviewAnalysisService

router = APIRouter(prefix="/places", tags=["places"])
recommendations = RecommendationService()


@router.get("/nearby")
def nearby_places(latitude: float, longitude: float, category: str | None = None, limit: int = 10, _: CurrentUser = None):
    query = NearbyQuery(latitude=latitude, longitude=longitude, category=category, limit=limit)
    return {"recommendations": recommendations.nearby(**query.model_dump()), "is_demo": True, "data_notice": "Demo listings are not live availability, price, hours, or emergency information."}


@router.get("/{place_id}")
def place_details(place_id: UUID, _: CurrentUser = None):
    place = recommendations.get_place(place_id)
    if not place:
        raise HTTPException(status_code=404, detail="Place not found")
    return {"place": place, "is_demo": True}


@router.post("/{place_id}/analyze-reviews")
def analyze_reviews(place_id: UUID, _: CurrentUser = None):
    place = recommendations.get_place(place_id)
    if not place:
        raise HTTPException(status_code=404, detail="Place not found")
    return ReviewAnalysisService().analyze(place)

