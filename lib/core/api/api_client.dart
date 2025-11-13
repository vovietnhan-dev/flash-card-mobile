import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiClient {
  late final Dio _dio;
  String? _token;
  bool _isInitialized = false;
  final _initLock = Completer<void>();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.timeout,
        receiveTimeout: ApiConfig.timeout,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    // Pretty Dio Logger - Beautiful and clean logging
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    // Auth Interceptor - Thêm token vào header
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Wait for initialization if not done yet
          if (!_isInitialized) {
            await _initLock.future;
          }

          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
            debugPrint('🔑 Request with token: ${_token!.substring(0, 20)}...');
          } else {
            debugPrint('⚠️ Request without token');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            debugPrint('❌ 401 Unauthorized - Token invalid or expired');
            // Token expired - logout
            await clearToken();
          }
          return handler.next(error);
        },
      ),
    );

    // Load token asynchronously
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      debugPrint('📱 Token loaded from storage: ${_token != null ? "${_token!.substring(0, 20)}..." : "null"}');
    } catch (e) {
      _token = null;
      debugPrint('⚠️ Failed to load token: $e');
    }
    
    _isInitialized = true;
    if (!_initLock.isCompleted) {
      _initLock.complete();
    }
  }

  Future<void> setToken(String token) async {
    _token = token; // Set immediately for synchronous access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    debugPrint('✅ Token set: ${token.substring(0, 20)}...');
  }

  Future<void> clearToken() async {
    _token = null; // Clear immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    debugPrint('🗑️ Token cleared');
  }

  bool get isAuthenticated => _token != null;

  // HTTP Methods
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } catch (e) {
      rethrow;
    }
  }
}
