import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/trip.dart';

class OfflineSnapshot {
  const OfflineSnapshot({this.token, this.trip});
  final String? token;
  final Trip? trip;
}

class OfflineStatusService {
  static const _tokenKey = 'session_token';
  static const _tripKey = 'active_trip';

  Future<OfflineSnapshot> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawTrip = preferences.getString(_tripKey);
    return OfflineSnapshot(token: preferences.getString(_tokenKey), trip: rawTrip == null ? null : Trip.fromJson(jsonDecode(rawTrip) as Map<String, dynamic>));
  }

  Future<void> saveSession(String token) async => (await SharedPreferences.getInstance()).setString(_tokenKey, token);
  Future<void> saveTrip(Trip trip) async => (await SharedPreferences.getInstance()).setString(_tripKey, jsonEncode(trip.toJson()));
  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    await preferences.remove(_tripKey);
  }
}

