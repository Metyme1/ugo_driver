import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _accessToken;

  final sessionExpired = ValueNotifier<bool>(false);

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        if (kDebugMode) print('REQUEST[${options.method}] => ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) print('RESPONSE[${response.statusCode}] => ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) print('ERROR[${error.response?.statusCode}] => ${error.requestOptions.path}');

        if (error.response?.statusCode == 401) {
          if (error.requestOptions.path.contains('refresh-token')) {
            _triggerSessionExpired();
            return handler.next(error);
          }
          final refreshed = await _refreshToken();
          if (refreshed) {
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $_accessToken';
            try {
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
        }
        return handler.next(error);
      },
    ));
  }

  void setAccessToken(String? token) => _accessToken = token;
  String? get accessToken => _accessToken;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(AppConstants.accessTokenKey);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accessTokenKey, accessToken);
    await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
    _accessToken = accessToken;
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    _accessToken = null;
  }

  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(AppConstants.refreshTokenKey);
      if (refreshToken == null) { _triggerSessionExpired(); return false; }

      final response = await _dio.post(ApiConfig.refreshToken, data: {'refresh_token': refreshToken});
      if (response.statusCode == 200) {
        final data = response.data['data'];
        await saveTokens(data['access_token'], data['refresh_token']);
        return true;
      }
      _triggerSessionExpired();
      return false;
    } catch (e) {
      _triggerSessionExpired();
      return false;
    }
  }

  void _triggerSessionExpired() {
    clearTokens();
    sessionExpired.value = !sessionExpired.value;
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _dio.post(path, data: data, queryParameters: queryParameters);

  Future<Response> put(String path, {dynamic data}) => _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server is waking up. Please wait and try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  String _handleResponseError(Response? response) {
    if (response == null) return 'No response from server.';
    final data = response.data;
    if (data is Map) {
      if (data['message'] != null) return data['message'];
      if (data['error'] is Map && data['error']['message'] != null) return data['error']['message'];
    }
    switch (response.statusCode) {
      case 400: return 'Bad request. Please check your input.';
      case 401: return 'Unauthorized. Please login again.';
      case 403: return 'Access denied.';
      case 404: return 'Not found.';
      case 409: return 'This account already exists.';
      case 500: return 'Server error. Please try again later.';
      default: return 'Error: ${response.statusCode}';
    }
  }
}
