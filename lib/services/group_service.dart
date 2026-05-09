import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/group_model.dart';
import 'api_service.dart';

class GroupService {
  final ApiService _api = ApiService();

  Future<ApiResponse<List<GroupModel>>> getMyGroups() async {
    try {
      final response = await _api.get(ApiConfig.myGroups);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final list = (data['groups'] as List? ?? [])
            .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(data: list);
      }
      return ApiResponse.failure(message: 'Failed to fetch groups');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<GroupModel>> getGroupDetail(String groupId) async {
    try {
      final response = await _api.get('/groups/$groupId');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return ApiResponse.success(data: GroupModel.fromJson(data['group'] ?? data));
      }
      return ApiResponse.failure(message: 'Failed to fetch group');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<ScanResult>> previewScan(String qrToken) async {
    try {
      final response = await _api.post(ApiConfig.scanQr, data: {'qr_token': qrToken});
      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: ScanResult.fromJson(response.data['data']),
          message: response.data['message'],
        );
      }
      return ApiResponse.failure(message: response.data['error']?['message'] ?? 'Scan failed');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> confirmScan(String purchaseId, int ridesCount) async {
    try {
      final response = await _api.post(ApiConfig.scanConfirm, data: {
        'purchase_id': purchaseId,
        'rides_count': ridesCount,
      });
      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: Map<String, dynamic>.from(response.data['data']),
          message: response.data['message'],
        );
      }
      return ApiResponse.failure(message: response.data['error']?['message'] ?? 'Confirmation failed');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }
}
