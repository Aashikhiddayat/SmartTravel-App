from fastapi import APIRouter

from app.dependencies import CurrentUser
from app.services.recommendations import RecommendationService

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.get("")
def recommendations(latitude: float = 10.0889, longitude: float = 77.0595, category: str | None = None, limit: int = 10, _: CurrentUser = None):
    """A compatibility endpoint for a user's current trip/explore context."""
    return {
        "recommendations": RecommendationService().nearby(latitude, longitude, category, limit),
        "algorithm": "rating + distance + budget + preference + safety",
        "is_demo": True,
    }

