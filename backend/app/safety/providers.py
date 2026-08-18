from typing import Protocol

from app.schemas.common import Alert, DangerZone


class SafetyDataProvider(Protocol):
    async def active_zones(self, *, latitude: float, longitude: float) -> list[DangerZone]: ...


class AlertProvider(Protocol):
    async def alerts_for_destination(self, destination: str) -> list[Alert]: ...


class NotificationProvider(Protocol):
    async def send(self, *, user_id: str, title: str, body: str, data: dict[str, str]) -> None: ...

