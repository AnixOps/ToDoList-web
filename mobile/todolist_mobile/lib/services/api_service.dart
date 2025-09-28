import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const Duration _timeout = Duration(seconds: 30);
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 获取认证头
  Map<String, String> get _headers {
    final token = _prefs.getString(StorageKeys.accessToken);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET请求
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      
      final response = await http.get(
        uri,
        headers: _headers,
      ).timeout(_timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // POST请求
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      
      final response = await http.post(
        uri,
        headers: _headers,
        body: data != null ? jsonEncode(data) : null,
      ).timeout(_timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // PUT请求
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      
      final response = await http.put(
        uri,
        headers: _headers,
        body: data != null ? jsonEncode(data) : null,
      ).timeout(_timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      
      final response = await http.delete(
        uri,
        headers: _headers,
      ).timeout(_timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // 构建URI
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse(endpoint);
    
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParams.map((key, value) => MapEntry(key, value.toString())),
      });
    }
    
    return uri;
  }

  // 处理响应
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;
    
    try {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      if (statusCode >= 200 && statusCode < 300) {
        // 成功响应
        if (fromJson != null && jsonData.containsKey('data')) {
          final data = fromJson(jsonData['data']);
          return ApiResponse.success(data, jsonData['message']);
        } else {
          return ApiResponse.success(jsonData as T?, jsonData['message']);
        }
      } else {
        // 错误响应
        final message = jsonData['message'] ?? jsonData['error'] ?? 'Unknown error';
        return ApiResponse.error(message, statusCode);
      }
    } catch (e) {
      // JSON解析错误
      if (statusCode >= 200 && statusCode < 300) {
        return ApiResponse.success(response.body as T?, null);
      } else {
        return ApiResponse.error('Invalid response format', statusCode);
      }
    }
  }

  // 处理异常
  String _handleError(dynamic error) {
    if (error is SocketException) {
      return '网络连接失败，请检查网络设置';
    } else if (error is HttpException) {
      return '服务器请求失败';
    } else if (error is FormatException) {
      return '数据格式错误';
    } else {
      return error.toString();
    }
  }

  // 保存Token
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _prefs.setString(StorageKeys.accessToken, accessToken);
    if (refreshToken != null) {
      await _prefs.setString(StorageKeys.refreshToken, refreshToken);
    }
  }

  // 清除Token
  Future<void> clearTokens() async {
    await _prefs.remove(StorageKeys.accessToken);
    await _prefs.remove(StorageKeys.refreshToken);
  }

  // 检查是否已登录
  bool get isLoggedIn {
    return _prefs.getString(StorageKeys.accessToken) != null;
  }
}

// API响应包装类
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  const ApiResponse._({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(T? data, String? message) {
    return ApiResponse._(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse._(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

// API异常类
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}