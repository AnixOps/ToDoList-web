import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/offline_storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final OfflineStorageService _offlineService = OfflineStorageService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;

  // 初始化
  Future<void> init() async {
    if (_isInitialized) return;

    _setLoading(true);

    try {
      await _authService.init();
      await _offlineService.init();

      // 检查是否是离线模式
      if (_offlineService.isOfflineMode) {
        _user = await _offlineService.getOfflineUser();
      } else if (_authService.isLoggedIn) {
        // 在线模式，检查是否有保存的用户信息
        _user = _authService.currentUser;
      }

      _isInitialized = true;
    } catch (e) {
      _setError('Initialization failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 初始化离线模式
  Future<void> initOfflineMode() async {
    _setLoading(true);
    _clearError();

    try {
      // 先初始化离线服务
      await _offlineService.init();

      // 检查是否已经有离线用户
      User? existingUser = await _offlineService.getOfflineUser();

      if (existingUser != null) {
        _user = existingUser;
      } else {
        // 创建新的离线用户
        _user = await _offlineService.createOfflineUser(
          name: '离线用户',
          email: 'offline@todolist.app',
        );
      }

      await _offlineService.setOfflineMode(true);
      notifyListeners();
    } catch (e) {
      String errorMessage = '初始化离线模式失败';
      if (e.toString().contains('databaseFactory not initialized')) {
        errorMessage += ': 数据库未正确初始化，请重启应用后重试';
      } else {
        errorMessage += ': ${e.toString()}';
      }
      _setError(errorMessage);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 登录
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result.isSuccess && result.data != null) {
        _user = result.data!.user;
        notifyListeners();
        return true;
      } else {
        _setError(result.message ?? '登录失败');
        return false;
      }
    } catch (e) {
      _setError('登录异常: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 注册
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      if (result.isSuccess && result.data != null) {
        _user = result.data!.user;
        notifyListeners();
        return true;
      } else {
        _setError(result.message ?? '注册失败');
        return false;
      }
    } catch (e) {
      _setError('注册异常: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 登出
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _user = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('登出异常: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 刷新用户信息
  Future<void> refreshUserInfo() async {
    if (!isLoggedIn) return;

    _setLoading(true);

    try {
      final result = await _authService.getCurrentUser();

      if (result.isSuccess && result.data != null) {
        _user = result.data;
        _clearError();
        notifyListeners();
      } else {
        _setError(result.message ?? '获取用户信息失败');
      }
    } catch (e) {
      _setError('获取用户信息异常: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 更新用户信息
  Future<bool> updateProfile({
    String? name,
    String? email,
  }) async {
    if (!isLoggedIn) return false;

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.updateProfile(
        name: name,
        email: email,
      );

      if (result.isSuccess && result.data != null) {
        _user = result.data;
        notifyListeners();
        return true;
      } else {
        _setError(result.message ?? '更新用户信息失败');
        return false;
      }
    } catch (e) {
      _setError('更新用户信息异常: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // 设置错误信息
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // 清除错误信息
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // 清除所有状态
  void clear() {
    _user = null;
    _isLoading = false;
    _error = null;
    _isInitialized = false;
    notifyListeners();
  }
}
