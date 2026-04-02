import 'user_model.dart';

class RegisterRequest {
  final String fullName;
  final String phone;
  final String password;
  final String confirmPassword;
  final String userType;

  RegisterRequest({
    required this.fullName,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    this.userType = 'driver',
  });

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'phone': phone,
        'password': password,
        'confirm_password': confirmPassword,
        'user_type': userType,
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
