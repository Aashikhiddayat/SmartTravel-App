from fastapi import APIRouter

from app.dependencies import CurrentUser
from app.repositories.demo_store import demo_store
from app.schemas.requests import ProfileUpsert

router = APIRouter(prefix="/auth", tags=["authentication"])


@router.post("/profile")
def save_profile(payload: ProfileUpsert, user_id: CurrentUser):
    demo_store.profiles[user_id] = payload.model_dump()
    return {"user_id": user_id, "profile": demo_store.profiles[user_id], "is_demo": True}


@router.get("/profile")
def get_profile(user_id: CurrentUser):
    return {"user_id": user_id, "profile": demo_store.profiles.get(user_id), "is_demo": True}

