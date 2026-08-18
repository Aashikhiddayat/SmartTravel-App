from math import asin, cos, radians, sin, sqrt


def distance_meters(latitude_a: float, longitude_a: float, latitude_b: float, longitude_b: float) -> float:
    """Haversine distance; sufficient for a small radius safety pre-filter."""
    earth_radius = 6_371_000
    d_lat = radians(latitude_b - latitude_a)
    d_lng = radians(longitude_b - longitude_a)
    a = sin(d_lat / 2) ** 2 + cos(radians(latitude_a)) * cos(radians(latitude_b)) * sin(d_lng / 2) ** 2
    return 2 * earth_radius * asin(sqrt(a))

