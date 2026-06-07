import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/driver_billing_model.dart';

class DriverBillingService {
  final ApiService _api;
  DriverBillingService(this._api);

  Future<DriverMonthlySummary> getMonthlySummary(String monthYear) async {
    try {
      final response = await _api.get(
        '/driver/billing/summary',
        queryParameters: {'monthYear': monthYear},
      );
      final data = response.data;
      if (data['success'] == true) {
        return DriverMonthlySummary.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception(data['error']?['message'] ?? 'Failed to fetch billing summary');
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  Future<List<DriverEarningRecord>> getEarnings({String? monthYear, int page = 1}) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (monthYear != null) params['monthYear'] = monthYear;
      final response = await _api.get('/driver/billing/earnings', queryParameters: params);
      final data = response.data;
      if (data['success'] == true) {
        final list = data['data']['earnings'] as List<dynamic>? ?? [];
        return list.map((e) => DriverEarningRecord.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception(data['error']?['message'] ?? 'Failed to fetch earnings');
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  Future<List<DriverPlatformSubscription>> getPlatformSubscriptions() async {
    try {
      final response = await _api.get('/driver/billing/platform-subscriptions');
      final data = response.data;
      if (data['success'] == true) {
        final list = data['data']['subscriptions'] as List<dynamic>? ?? [];
        return list
            .map((e) => DriverPlatformSubscription.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(data['error']?['message'] ?? 'Failed to fetch platform subscriptions');
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  Future<void> submitPlatformFeePayment({
    required String subscriptionId,
    required String paymentRef,
    required String paymentBank,
  }) async {
    try {
      final response = await _api.post(
        '/driver/billing/platform-subscriptions/$subscriptionId/pay',
        data: {'paymentRef': paymentRef, 'paymentBank': paymentBank},
      );
      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['error']?['message'] ?? 'Failed to submit payment');
      }
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  Future<DriverWalletOverview> getWalletOverview() async {
    try {
      final response = await _api.get('/driver/billing/wallet-overview');
      final data = response.data;
      if (data['success'] == true) {
        return DriverWalletOverview.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception(data['error']?['message'] ?? 'Failed to fetch wallet overview');
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  Future<void> requestEarlyRelease({required String subscriptionId, String? note}) async {
    try {
      final response = await _api.post(
        '/driver/billing/subscriptions/$subscriptionId/early-release-request',
        data: {if (note != null && note.isNotEmpty) 'note': note},
      );
      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['error']?['message'] ?? 'Failed to submit early-release request');
      }
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  Future<List<DriverEarlyReleaseRequest>> getEarlyReleaseRequests() async {
    try {
      final response = await _api.get('/driver/billing/early-release-requests');
      final data = response.data;
      if (data['success'] == true) {
        final list = data['data']['requests'] as List<dynamic>? ?? [];
        return list
            .map((e) => DriverEarlyReleaseRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(data['error']?['message'] ?? 'Failed to fetch early-release requests');
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  Future<List<Map<String, dynamic>>> getBanks() async {
    try {
      final response = await _api.get('/payment/banks');
      final data = response.data;
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']['banks'] as List);
      }
      throw Exception(data['error']?['message'] ?? 'Failed to fetch banks');
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }

  Future<String> requestWithdrawal({
    required double amount,
    required String bankCode,
    required String accountNumber,
    required String accountName,
  }) async {
    try {
      final response = await _api.post(
        '/driver/billing/withdraw',
        data: {
          'amount': amount,
          'bankCode': bankCode,
          'accountNumber': accountNumber,
          'accountName': accountName,
        },
      );
      final data = response.data;
      if (data['success'] == true) {
        return data['data']['reference'] as String? ?? '';
      }
      throw Exception(data['error']?['message'] ?? 'Withdrawal failed');
    } on DioException catch (e) {
      throw Exception(_api.handleError(e));
    }
  }
}
