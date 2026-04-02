import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationsService {
  final ApiService _api = ApiService();

  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    try {
      final response = await _api.get(ApiConfig.notifications);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final list = (data['notifications'] as List? ?? data as List? ?? [])
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(data: list);
      }
      return ApiResponse.failure(message: 'Failed to fetch notifications');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<void>> markAsRead(String id) async {
    try {
      await _api.put('${ApiConfig.notifications}/$id/read');
      return ApiResponse.success();
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<void>> markAllAsRead() async {
    try {
      await _api.put('${ApiConfig.notifications}/read-all');
      return ApiResponse.success();
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }
}
