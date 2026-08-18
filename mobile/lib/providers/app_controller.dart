import 'package:flutter/foundation.dart';

import '../core/app_config.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/offline_status_service.dart';

class AppController extends ChangeNotifier {
  AppController({OfflineStatusService? offline, AuthService? auth}) : _offline = offline ?? OfflineStatusService(), _auth = auth ?? AuthService();

  final OfflineStatusService _offline;
  final AuthService _auth;
  String? _token;
  Trip? activeTrip;
  bool loading = true;
  bool offlineBanner = false;
  String? error;

  bool get signedIn => _token != null;
  bool get demoMode => AppConfig.demoMode;
  TripRepository get trips => TripRepository(ApiClient(accessToken: _token ?? 'demo-user'));
  ApiClient get api => ApiClient(accessToken: _token ?? 'demo-user');

  Future<void> initialize() async {
    final snapshot = await _offline.load();
    _token = snapshot.token;
    activeTrip = snapshot.trip;
    loading = false;
    offlineBanner = activeTrip != null;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    error = null;
    notifyListeners();
    try {
      _token = await _auth.signIn(email, password);
      await _offline.saveSession(_token!);
    } catch (exception) {
      error = exception.toString();
    }
    notifyListeners();
  }

  Future<void> signInDemo() => signIn(email: 'demo@smarttrip.local', password: 'demo');

  Future<void> createTrip({required String title, required String destination, required DateTime startDate, required DateTime endDate, required double budget}) async {
    error = null;
    notifyListeners();
    try {
      activeTrip = await trips.createTrip(title: title, destination: destination, startDate: startDate, endDate: endDate, budget: budget);
      await _offline.saveTrip(activeTrip!);
      offlineBanner = false;
    } catch (exception) {
      error = 'Could not create trip. Check the API connection: $exception';
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _offline.clearSession();
    _token = null;
    activeTrip = null;
    offlineBanner = false;
    notifyListeners();
  }
}

