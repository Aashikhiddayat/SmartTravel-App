from typing import Protocol

from app.schemas.common import Place


class PlacesProvider(Protocol):
    async def nearby(self, *, latitude: float, longitude: float, category: str | None, limit: int) -> list[Place]: ...


class ReviewProvider(Protocol):
    async def permitted_reviews(self, external_place_id: str) -> list[dict]: ...


class DemoPlacesProvider:
    """Used only with demo data; real adapters use approved official APIs."""

    async def nearby(self, *, latitude: float, longitude: float, category: str | None, limit: int) -> list[Place]:
        from app.repositories.demo_store import demo_store
        return [place for place in demo_store.places if category is None or place.category == category][:limit]

