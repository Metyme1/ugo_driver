import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/university_scan_model.dart';

class UniversityScanService {
  final ApiService _api;
  UniversityScanService(this._api);

  Future<UniversityBookingPreview> previewScan(String bookingCode) async {
    try {
      final response = await _api.get(
        '/university-rides/driver/scan-preview',
        queryParameters: {'code': bookingCode},
      );
      final data = response.data;
      if (data['success'] == true) {
        return UniversityBookingPreview.fromJson(
          data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(
        data['error']?['message'] ?? data['message'] ?? 'Scan preview failed',
      );
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  Future<UniversityScanResult> confirmScan(String bookingId) async {
    try {
      final response = await _api.put(
        '/university-rides/driver/bookings/$bookingId/scan',
      );
      final data = response.data;
      if (data['success'] == true) {
        return UniversityScanResult.fromJson(
          data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception(
        data['error']?['message'] ?? data['message'] ?? 'Boarding confirmation failed',
      );
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }
}
