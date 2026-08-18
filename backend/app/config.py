from functools import lru_cache
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """All sensitive settings remain server-side and come from the environment."""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")
    app_env: Literal["development", "test", "production"] = "development"
    demo_mode: bool = True
    mock_ai: bool = True
    log_level: str = "INFO"
    api_cors_origins: str = "http://localhost:3000,http://10.0.2.2:8000"
    supabase_url: str | None = None
    supabase_anon_key: str | None = None
    supabase_service_role_key: str | None = None
    openai_api_key: str | None = None
    google_maps_api_key: str | None = None
    firebase_project_id: str | None = None
    maptiler_key: str | None = None
    offline_map_style_url: str | None = None

    @property
    def cors_origins(self) -> list[str]:
        return [origin.strip() for origin in self.api_cors_origins.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()

