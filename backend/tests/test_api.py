from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)
HEADERS_A = {"Authorization": "Bearer demo-user-a", "X-Demo-User": "demo-user-a"}
HEADERS_B = {"Authorization": "Bearer demo-user-b", "X-Demo-User": "demo-user-b"}


def create_trip() -> str:
    response = client.post("/trips", headers=HEADERS_A, json={"title": "Kerala demo", "destination": "Munnar, Kerala", "start_date": "2026-10-01", "end_date": "2026-10-05", "budget": 20000, "currency": "INR"})
    assert response.status_code == 201
    return response.json()["trip"]["id"]


def test_health_reports_mode():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_trip_plan_expense_and_receipt_confirmation():
    trip_id = create_trip()
    plan = client.post(f"/trips/{trip_id}/plan", headers=HEADERS_A, json={"travellers": 1, "travel_style": "Balanced", "interests": ["Nature"], "food_preferences": ["Vegetarian"], "accommodation_preference": "Comfortable", "preferred_pace": "balanced"})
    assert plan.status_code == 200
    assert len(plan.json()["itinerary"]) == 5
    expense = client.post(f"/expenses?trip_id={trip_id}", headers=HEADERS_A, json={"category": "Food", "amount": 450, "currency": "INR", "description": "Lunch", "merchant": "Demo Cafe", "expense_date": "2026-10-01"})
    assert expense.status_code == 201
    summary = client.get(f"/expenses/summary?trip_id={trip_id}", headers=HEADERS_A)
    assert summary.json()["summary"]["total_spent"] == 450
    receipt = client.post("/expenses/receipt-scan", headers=HEADERS_A, json={"trip_id": trip_id, "ocr_text": "Demo Cafe\nTotal INR 450"})
    assert receipt.status_code == 200
    assert receipt.json()["draft"]["requires_confirmation"] is True


def test_user_cannot_access_another_users_trip():
    trip_id = create_trip()
    response = client.get(f"/trips/{trip_id}", headers=HEADERS_B)
    assert response.status_code == 404


def test_demo_geofence_is_explicitly_disclosed():
    response = client.post("/safety/check-location", headers=HEADERS_A, json={"latitude": 10.1185, "longitude": 77.1025})
    assert response.status_code == 200
    assert response.json()["status"] == "danger"
    assert response.json()["is_demo"] is True


def test_replan_assistant_group_settlement_and_magazine_flow():
    trip_id = create_trip()
    invite = client.post(f"/trips/{trip_id}/members", headers=HEADERS_A, json={"user_id": "demo-user-b", "role": "member"})
    assert invite.status_code == 201
    shared_expense = client.post(f"/expenses?trip_id={trip_id}", headers=HEADERS_B, json={"category": "Transport", "amount": 1200, "currency": "INR", "description": "Shared taxi", "expense_date": "2026-10-01"})
    assert shared_expense.status_code == 201
    settlement = client.get(f"/trips/{trip_id}/settlements", headers=HEADERS_A)
    assert settlement.status_code == 200
    assert settlement.json()["fair_share"] == 600
    replan = client.post(f"/trips/{trip_id}/replan", headers=HEADERS_A, json={"travellers": 1, "travel_style": "Balanced", "interests": [], "food_preferences": [], "accommodation_preference": "Comfortable", "preferred_pace": "balanced", "trigger": "weather", "detail": "Demo heavy rain"})
    assert replan.status_code == 200
    assistant = client.post("/assistant/chat", headers=HEADERS_A, json={"trip_id": trip_id, "message": "How much budget remains?"})
    assert assistant.status_code == 200
    assert "remaining" in assistant.json()["answer"]
    magazine = client.post(f"/magazines/generate?trip_id={trip_id}", headers=HEADERS_A)
    assert magazine.status_code == 200
    assert magazine.json()["magazine"]["status"] == "ready"
