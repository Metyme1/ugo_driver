import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';
import '../models/daily_trip_model.dart';

class DriverTripService {
  final ApiService _api;
  DriverTripService(this._api);

  /// GET /api/driver/trips/today
  Future<List<DriverDailyTrip>> getTodayTrips() async {
    try {
      final response = await _api.get('/driver/trips/today');
      final data = response.data;
      if (data['success'] == true) {
        final list = data['data']['trips'] as List<dynamic>? ?? [];
        return list
            .map((t) => DriverDailyTrip.fromJson(t as Map<String, dynamic>))
            .toList();
      }
      throw Exception(data['error']?['message'] ?? 'Failed to fetch trips');
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  /// POST /api/driver/trips/:tripId/start
  Future<void> startTrip(String tripId) async {
    try {
      final response = await _api.post('/driver/trips/$tripId/start');
      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['error']?['message'] ?? 'Failed to start trip');
      }
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  /// PUT /api/driver/trips/:tripId/location
  /// Returns true if the backend accepted the update, false otherwise.
  Future<bool> updateLocation(String tripId, double lat, double lng) async {
    try {
      final response = await _api.put(
        '/driver/trips/$tripId/location',
        data: {'latitude': lat, 'longitude': lng},
      );
      return response.data['success'] == true;
    } on DioException catch (_) {
      return false;
    }
  }

  /// POST /api/driver/trips/:tripId/pickup/:childId
  Future<void> pickupStudent(String tripId, String childId) async {
    try {
      final response = await _api.post('/driver/trips/$tripId/pickup/$childId');
      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['error']?['message'] ?? 'Failed to mark pickup');
      }
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  /// POST /api/driver/trips/:tripId/dropoff/:childId
  Future<void> dropoffStudent(String tripId, String childId) async {
    try {
      final response = await _api.post('/driver/trips/$tripId/dropoff/$childId');
      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['error']?['message'] ?? 'Failed to mark dropoff');
      }
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  /// POST /api/driver/trips/:tripId/complete
  Future<void> completeTrip(String tripId) async {
    try {
      final response = await _api.post('/driver/trips/$tripId/complete');
      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['error']?['message'] ?? 'Failed to complete trip');
      }
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  /// GET /api/trips/:tripId/students
  Future<List<StudentTripStatus>> getTripStudents(String tripId) async {
    try {
      final response = await _api.get('/trips/$tripId/students');
      final data = response.data;
      if (data['success'] == true) {
        final trip = data['data']['trip'];
        final list = trip['student_statuses'] as List<dynamic>? ?? [];
        return list
            .map((s) => StudentTripStatus.fromJson(s as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  /// Requests location permission and returns current position.
  /// Returns null if permission denied.
  static Future<Position?> getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (_) {
      return null;
    }
  }
}
