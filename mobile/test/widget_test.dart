import 'package:flutter_test/flutter_test.dart';
import 'package:smart_trip/models/trip.dart';

void main() {
  test('Trip serializes a cached offline snapshot', () {
    final trip = Trip(id: 'test-trip', title: 'Kerala', destination: 'Munnar', startDate: DateTime(2026, 1, 1), endDate: DateTime(2026, 1, 5), budget: 20000, currency: 'INR');
    final restored = Trip.fromJson(trip.toJson());
    expect(restored.destination, 'Munnar');
    expect(restored.budget, 20000);
  });
}

