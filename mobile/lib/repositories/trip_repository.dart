import '../models/place.dart';
import '../models/trip.dart';
import '../services/api_client.dart';

class TripRepository {
  TripRepository(this.api);
  final ApiClient api;

  Future<List<Trip>> listTrips() async {
    final response = await api.get('/trips');
    return (response['trips'] as List<dynamic>).map((item) => Trip.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Trip> createTrip({required String title, required String destination, required DateTime startDate, required DateTime endDate, required double budget}) async {
    final response = await api.post('/trips', {'title': title, 'destination': destination, 'start_date': _date(startDate), 'end_date': _date(endDate), 'budget': budget, 'currency': 'INR'});
    return Trip.fromJson(response['trip'] as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> plan(Trip trip) async {
    final response = await api.post('/trips/${trip.id}/plan', {'travellers': 1, 'travel_style': 'Balanced', 'interests': ['Nature', 'Food', 'Photography'], 'food_preferences': ['Vegetarian'], 'accommodation_preference': 'Comfortable', 'preferred_pace': 'balanced'});
    return List<Map<String, dynamic>>.from(response['itinerary'] as List<dynamic>);
  }

  Future<List<PlaceRecommendation>> nearby({String? category}) async {
    final query = {'latitude': '10.0889', 'longitude': '77.0595', 'limit': '12', if (category != null) 'category': category};
    final response = await api.get('/places/nearby', query);
    return (response['recommendations'] as List<dynamic>).map((item) => PlaceRecommendation.fromJson(item as Map<String, dynamic>)).toList();
  }

  static String _date(DateTime date) => date.toIso8601String().split('T').first;
}

