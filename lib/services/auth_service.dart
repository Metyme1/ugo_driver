import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<ApiResponse<RegisterResponse>> register(RegisterRequest request) async {
    try {
      final response = await _api.post(ApiConfig.register, data: request.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return ApiResponse.success(
          data: RegisterResponse.fromJson(data),
          message: response.data['message'] ?? 'OTP sent successfully',
        );
      }
      return ApiResponse.failure(message: response.data['message'] ?? 'Registration failed');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _api.post(ApiConfig.login, data: request.toJson());
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final authResponse = AuthResponse.fromJson(data);
        await _api.saveTokens(authResponse.tokens.accessToken, authResponse.tokens.refreshToken);
        return ApiResponse.success(data: authResponse, message: 'Login successful');
      }
      return ApiResponse.failure(message: response.data['message'] ?? 'Login failed');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<AuthResponse>> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _api.post(ApiConfig.verifyOtp, data: request.toJson());
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final authResponse = AuthResponse.fromJson(data);
        await _api.saveTokens(authResponse.tokens.accessToken, authResponse.tokens.refreshToken);
        return ApiResponse.success(data: authResponse, message: 'Verified');
      }
      return ApiResponse.failure(message: response.data['message'] ?? 'Verification failed');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<void>> resendOtp(String phone, String purpose) async {
    try {
      final response = await _api.post(ApiConfig.resendOtp, data: {'phone': phone, 'purpose': purpose});
      if (response.statusCode == 200) return ApiResponse.success(message: 'OTP sent');
      return ApiResponse.failure(message: response.data['message'] ?? 'Failed');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<void>> forgotPassword(String phone) async {
    try {
      final response = await _api.post(ApiConfig.forgotPassword, data: {'phone': phone});
      if (response.statusCode == 200) return ApiResponse.success(message: 'OTP sent');
      return ApiResponse.failure(message: response.data['message'] ?? 'Failed');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<void>> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _api.post(ApiConfig.resetPassword, data: {
        'phone': phone,
        'otp': otp,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });
      if (response.statusCode == 200) return ApiResponse.success(message: 'Password reset');
      return ApiResponse.failure(message: response.data['message'] ?? 'Failed');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await _api.get(ApiConfig.me);
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ApiResponse.success(data: UserModel.fromJson(data['user'] ?? data));
      }
      return ApiResponse.failure(message: 'Failed to get user');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      await _api.post(ApiConfig.logout);
      await _api.clearTokens();
      return ApiResponse.success(message: 'Logged out');
    } catch (e) {
      await _api.clearTokens();
      return ApiResponse.success(message: 'Logged out');
    }
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _api.post(ApiConfig.changePassword, data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });
      if (response.statusCode == 200) return ApiResponse.success(message: 'Password changed');
      return ApiResponse.failure(message: response.data['message'] ?? 'Failed');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }

  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _api.put(ApiConfig.updateProfile, data: data);
      if (response.statusCode == 200) {
        final resData = response.data['data'] ?? response.data;
        return ApiResponse.success(data: UserModel.fromJson(resData['user'] ?? resData));
      }
      return ApiResponse.failure(message: response.data['message'] ?? 'Failed');
    } on DioException catch (e) {
      return ApiResponse.failure(message: _api.handleError(e));
    }
  }
}
