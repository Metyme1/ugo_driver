import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/nomination_model.dart';
import 'api_service.dart';

class NominationService {
  final ApiService _api = ApiService();

  Future<ApiResponse<List<DriverNomination>>> getMyNominations() async {
    try {
      final response = await _api.get(ApiConfig.myNominations);
      if (response.statusCode == 200) {
        final list = (response.data['data']['nominations'] as List? ?? [])
            .map((e) => DriverNomination.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(data: list);
      }
      return ApiResponse.failure(message: 'Failed to fetch nominations');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<void>> respondToNomination(String groupId, String response) async {
    try {
      final res = await _api.post(
        '/driver/groups/$groupId/respond',
        data: {'response': response},
      );
      if (res.data['success'] == true) return ApiResponse.success(message: 'Response sent');
      return ApiResponse.failure(message: res.data['error']?['message'] ?? 'Failed');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }
}
