from typing import Protocol


class AIProvider(Protocol):
    """A production implementation must use schema-constrained model output."""

    async def generate_json(self, *, task: str, context: dict) -> dict: ...


class MockAIProvider:
    """Deterministic no-key development provider; never represent its output as live facts."""

    async def generate_json(self, *, task: str, context: dict) -> dict:
        return {"task": task, "context_keys": sorted(context), "is_demo": True}

