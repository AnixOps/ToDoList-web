import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 登录
  Future<ApiResponse<AuthResult>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        
        // 保存Token
        await _apiService.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        
        // 保存用户信息
        final user = User.fromJson(data['user']);
        await _saveUserInfo(user);
        
        return ApiResponse.success(
          AuthResult(user: user, accessToken: data['access_token']),
          response.message,
        );
      } else {
        return ApiResponse.error(response.message ?? '登录失败');
      }
    } catch (e) {
      return ApiResponse.error('登录异常: ${e.toString()}');
    }
  }

  // 注册
  Future<ApiResponse<AuthResult>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        
        // 保存Token
        await _apiService.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        
        // 保存用户信息
        final user = User.fromJson(data['user']);
        await _saveUserInfo(user);
        
        return ApiResponse.success(
          AuthResult(user: user, accessToken: data['access_token']),
          response.message,
        );
      } else {
        return ApiResponse.error(response.message ?? '注册失败');
      }
    } catch (e) {
      return ApiResponse.error('注册异常: ${e.toString()}');
    }
  }

  // 刷新Token
  Future<ApiResponse<String>> refreshToken() async {
    try {
      final refreshToken = _prefs.getString(StorageKeys.refreshToken);
      if (refreshToken == null) {
        return ApiResponse.error('没有刷新令牌');
      }

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.refresh,
        data: {
          'refresh_token': refreshToken,
        },
      );

      if (response.isSuccess && response.data != null) {
        final accessToken = response.data!['access_token'];
        await _apiService.saveTokens(accessToken: accessToken);
        
        return ApiResponse.success(accessToken, response.message);
      } else {
        return ApiResponse.error(response.message ?? '刷新令牌失败');
      }
    } catch (e) {
      return ApiResponse.error('刷新令牌异常: ${e.toString()}');
    }
  }

  // 登出
  Future<void> logout() async {
    try {
      // 清除本地存储的认证信息
      await _apiService.clearTokens();
      await _clearUserInfo();
      
      // 可以在这里调用后端登出接口
      // await _apiService.post(ApiConstants.logout);
    } catch (e) {
      // 即使请求失败，也要清除本地信息
      await _apiService.clearTokens();
      await _clearUserInfo();
    }
  }

  // 获取当前用户信息
  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.profile,
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final user = User.fromJson(response.data!);
        await _saveUserInfo(user);
        return ApiResponse.success(user, response.message);
      } else {
        return ApiResponse.error(response.message ?? '获取用户信息失败');
      }
    } catch (e) {
      return ApiResponse.error('获取用户信息异常: ${e.toString()}');
    }
  }

  // 更新用户信息
  Future<ApiResponse<User>> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;

      final response = await _apiService.put<Map<String, dynamic>>(
        ApiConstants.updateProfile,
        data: data,
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final user = User.fromJson(response.data!);
        await _saveUserInfo(user);
        return ApiResponse.success(user, response.message);
      } else {
        return ApiResponse.error(response.message ?? '更新用户信息失败');
      }
    } catch (e) {
      return ApiResponse.error('更新用户信息异常: ${e.toString()}');
    }
  }

  // 检查是否已登录
  bool get isLoggedIn => _apiService.isLoggedIn;

  // 获取本地保存的用户信息
  User? get currentUser {
    final userId = _prefs.getInt(StorageKeys.userId);
    final userEmail = _prefs.getString(StorageKeys.userEmail);
    final userName = _prefs.getString(StorageKeys.userName);
    
    if (userId != null && userEmail != null && userName != null) {
      return User(
        id: userId,
        email: userEmail,
        name: userName,
        createdAt: DateTime.now(), // 本地存储中没有这些字段
        updatedAt: DateTime.now(),
      );
    }
    
    return null;
  }

  // 保存用户信息到本地
  Future<void> _saveUserInfo(User user) async {
    await _prefs.setInt(StorageKeys.userId, user.id);
    await _prefs.setString(StorageKeys.userEmail, user.email);
    await _prefs.setString(StorageKeys.userName, user.name);
  }

  // 清除本地用户信息
  Future<void> _clearUserInfo() async {
    await _prefs.remove(StorageKeys.userId);
    await _prefs.remove(StorageKeys.userEmail);
    await _prefs.remove(StorageKeys.userName);
  }
}

// 认证结果类
class AuthResult {
  final User user;
  final String accessToken;

  const AuthResult({
    required this.user,
    required this.accessToken,
  });
}