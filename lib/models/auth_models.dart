import 'dart:io';
import 'user_model.dart';

class RegisterRequest {
  final String fullName;
  final String phone;
  final String password;
  final String confirmPassword;
  final String userType;

  // Personal info
  final String? dateOfBirth;
  final String? educationLevel;
  final String? nationalIdNumber;
  final File? nationalIdImage;

  // License
  final String? licenseNumber;
  final String? licenseExpiry;

  // Vehicle
  final String? vehicleType;
  final String? plateNumber;
  final String? vehicleColor;
  final String? vehicleModel;

  RegisterRequest({
    required this.fullName,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    this.userType = 'driver',
    this.dateOfBirth,
    this.educationLevel,
    this.nationalIdNumber,
    this.nationalIdImage,
    this.licenseNumber,
    this.licenseExpiry,
    this.vehicleType,
    this.plateNumber,
    this.vehicleColor,
    this.vehicleModel,
  });

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'phone': phone,
        'password': password,
        'confirm_password': confirmPassword,
        'user_type': userType,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (educationLevel != null) 'education_level': educationLevel,
        if (nationalIdNumber != null) 'national_id_number': nationalIdNumber,
        if (licenseNumber != null) 'license_number': licenseNumber,
        if (licenseExpiry != null) 'license_expiry': licenseExpiry,
        if (vehicleType != null) 'vehicle_type': vehicleType,
        if (plateNumber != null) 'plate_number': plateNumber,
        if (vehicleColor != null) 'vehicle_color': vehicleColor,
        if (vehicleModel != null) 'vehicle_model': vehicleModel,
      };
}

class LoginRequest {
  final String phone;
  final String password;
  LoginRequest({required this.phone, required this.password});
  Map<String, dynamic> toJson() => {'phone': phone, 'password': password};
}

class VerifyOtpRequest {
  final String phone;
  final String otp;
  final String purpose;
  VerifyOtpRequest({required this.phone, required this.otp, required this.purpose});
  Map<String, dynamic> toJson() => {'phone': phone, 'otp': otp, 'purpose': purpose};
}

class TokenData {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  TokenData({required this.accessToken, required this.refreshToken, required this.expiresIn});

  factory TokenData.fromJson(Map<String, dynamic> json) => TokenData(
        accessToken: json['access_token'] ?? json['accessToken'] ?? '',
        refreshToken: json['refresh_token'] ?? json['refreshToken'] ?? '',
        expiresIn: json['expires_in'] ?? json['expiresIn'] ?? 3600,
      );
}

class AuthResponse {
  final UserModel user;
  final TokenData tokens;
  final String? nextStep;

  AuthResponse({required this.user, required this.tokens, this.nextStep});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        user: UserModel.fromJson(json['user']),
        tokens: TokenData.fromJson(json['tokens']),
        nextStep: json['next_step'],
      );
}

class RegisterResponse {
  final String userId;
  final String phone;
  final int otpExpiresIn;

  RegisterResponse({required this.userId, required this.phone, required this.otpExpiresIn});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        userId: json['user_id'] ?? json['userId'] ?? json['id'] ?? '',
        phone: json['phone'] ?? '',
        otpExpiresIn: json['otp_expires_in'] ?? json['otpExpiresIn'] ?? 300,
      );
}
