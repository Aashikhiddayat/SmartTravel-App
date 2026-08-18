"""Authentication and authorization boundaries.

The mobile app only carries the Supabase anon key/session token. Service-role and
OpenAI keys never leave the API process.
"""
from typing import Annotated

import httpx
from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.config import Settings, get_settings

bearer = HTTPBearer(auto_error=False)


async def current_user_id(
    request: Request,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer)],
    settings: Annotated[Settings, Depends(get_settings)],
) -> str:
    if settings.demo_mode:
        # This is intentionally available only when DEMO_MODE is explicitly active.
        supplied = request.headers.get("X-Demo-User") or (credentials.credentials if credentials else None)
        return supplied or "demo-user"
    if not credentials or not settings.supabase_url or not settings.supabase_anon_key:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="A valid Supabase session is required")
    try:
        async with httpx.AsyncClient(timeout=5) as client:
            response = await client.get(
                f"{settings.supabase_url.rstrip('/')}/auth/v1/user",
                headers={"apikey": settings.supabase_anon_key, "Authorization": f"Bearer {credentials.credentials}"},
            )
            response.raise_for_status()
            user_id = response.json().get("id")
    except (httpx.HTTPError, ValueError) as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Session validation failed") from exc
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Session did not identify a user")
    return str(user_id)


CurrentUser = Annotated[str, Depends(current_user_id)]

