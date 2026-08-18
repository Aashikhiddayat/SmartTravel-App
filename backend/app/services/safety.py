from app.repositories.demo_store import demo_store
from app.services.geo import distance_meters


class SafetyService:
    def check_location(self, latitude: float, longitude: float) -> dict:
        nearby = []
        for zone in demo_store.zones:
            distance = distance_meters(latitude, longitude, zone.latitude, zone.longitude)
            if distance <= zone.radius_meters * 1.5:
                nearby.append({"zone": zone, "distance_meters": round(distance), "inside": distance <= zone.radius_meters})
        inside = [record for record in nearby if record["inside"]]
        highest = next((record for record in inside if record["zone"].risk_level == "high"), None)
        if highest:
            message = "DEMO: You have entered a marked high-risk area. Move toward a safer area. This is not an official alert."
            status = "danger"
        elif inside:
            message = "DEMO: You are inside a marked caution area. Check verified local guidance."
            status = "caution"
        elif nearby:
            message = "DEMO: You are approaching a marked caution area. This data is not official."
            status = "caution"
        else:
            message = "No demo zone intersects this location. This does not establish that the area is safe."
            status = "clear"
        return {"status": status, "message": message, "matches": nearby, "last_updated": "Demo seed", "is_demo": True}

    def check_route(self, points: list[tuple[float, float]]) -> dict:
        intersections = []
        for point in points:
            match = self.check_location(point[0], point[1])
            intersections.extend([entry for entry in match["matches"] if entry["inside"]])
        unique = {str(entry["zone"].id): entry for entry in intersections}.values()
        zones = list(unique)
        return {"is_safer_route": not zones, "intersected_zones": zones, "recommendation": "Use an alternate verified route if it avoids the demo zone." if zones else "No demo zone intersects this route; check live conditions independently.", "is_demo": True}

