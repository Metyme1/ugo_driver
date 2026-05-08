import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../config/constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  UserModel? _user;
  String? _errorMessage;
  String? _pendingPhone;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get pendingPhone => _pendingPhone;

  void _setLoading(bool value) { _isLoading = value; notifyListeners(); }
  void _setError(String? msg) { _errorMessage = msg; notifyListeners(); }
  void clearError() { _errorMessage = null; notifyListeners(); }

  String _formatPhone(String phone) {
    phone = phone.trim();
    if (phone.startsWith('0')) return '${AppConstants.phonePrefix}${phone.substring(1)}';
    if (!phone.startsWith('+')) return '${AppConstants.phonePrefix}$phone';
    return phone;
  }

  Future<void> init() async {
    _apiService.init();
    await _apiService.loadToken();
    if (_apiService.accessToken != null) await getCurrentUser();
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String password,
    required String confirmPassword,
    String? dateOfBirth,
    String? educationLevel,
    String? nationalIdNumber,
    File? nationalIdImage,
    String? licenseNumber,
    String? licenseExpiry,
    String? vehicleType,
    String? plateNumber,
    String? vehicleColor,
    String? vehicleModel,
  }) async {
    _setLoading(true);
    _setError(null);
    final formatted = _formatPhone(phone);
    _pendingPhone = formatted;

    final response = await _authService.register(RegisterRequest(
      fullName: fullName,
      phone: formatted,
      password: password,
      confirmPassword: confirmPassword,
      userType: 'driver',
      dateOfBirth: dateOfBirth,
      educationLevel: educationLevel,
      nationalIdNumber: nationalIdNumber,
      nationalIdImage: nationalIdImage,
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
      vehicleType: vehicleType,
      plateNumber: plateNumber,
      vehicleColor: vehicleColor,
      vehicleModel: vehicleModel,
    ));
    _setLoading(false);
    if (response.success) { notifyListeners(); return true; }
    _setError(response.error?.message ?? 'Registration failed');
    return false;
  }

  Future<bool> login({required String phone, required String password}) async {
    _setLoading(true);
    _setError(null);
    final formatted = _formatPhone(phone);
    final response = await _authService.login(LoginRequest(phone: formatted, password: password));
    _setLoading(false);
    if (response.success && response.data != null) {
      _user = response.data!.user;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    _setError(response.error?.message ?? 'Login failed');
    return false;
  }

  Future<bool> verifyOtp({required String phone, required String otp, required String purpose}) async {
    _setLoading(true);
    _setError(null);
    final formatted = _formatPhone(phone);
    final response = await _authService.verifyOtp(VerifyOtpRequest(phone: formatted, otp: otp, purpose: purpose));
    _setLoading(false);
    if (response.success && response.data != null) {
      _user = response.data!.user;
      _isAuthenticated = true;
      _pendingPhone = null;
      notifyListeners();
      return true;
    }
    _setError(response.error?.message ?? 'Verification failed');
    return false;
  }

  Future<bool> resendOtp({required String phone, required String purpose}) async {
    _setLoading(true);
    final response = await _authService.resendOtp(_formatPhone(phone), purpose);
    _setLoading(false);
    if (response.success) return true;
    _setError(response.error?.message ?? 'Failed');
    return false;
  }

  Future<bool> forgotPassword(String phone) async {
    _setLoading(true);
    _setError(null);
    final formatted = _formatPhone(phone);
    _pendingPhone = formatted;
    final response = await _authService.forgotPassword(formatted);
    _setLoading(false);
    if (response.success) return true;
    _setError(response.error?.message ?? 'Failed');
    return false;
  }

  Future<bool> resetPassword({
    required String phone, required String otp,
    required String newPassword, required String confirmPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    final response = await _authService.resetPassword(
      phone: _formatPhone(phone), otp: otp,
      newPassword: newPassword, confirmPassword: confirmPassword,
    );
    _setLoading(false);
    if (response.success) { _pendingPhone = null; return true; }
    _setError(response.error?.message ?? 'Failed');
    return false;
  }

  Future<bool> getCurrentUser() async {
    final response = await _authService.getCurrentUser();
    if (response.success && response.data != null) {
      _user = response.data;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    _pendingPhone = null;
    _setLoading(false);
  }

  Future<bool> updateProfile({String? firstName, String? lastName, String? email}) async {
    _setLoading(true);
    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (email != null) data['email'] = email;

    final response = await _authService.updateProfile(data);
    _setLoading(false);
    if (response.success && response.data != null) {
      _user = response.data;
      notifyListeners();
      return true;
    }
    _setError(response.error?.message ?? 'Update failed');
    return false;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    final response = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    _setLoading(false);
    if (response.success) return true;
    _setError(response.error?.message ?? 'Failed');
    return false;
  }
}
