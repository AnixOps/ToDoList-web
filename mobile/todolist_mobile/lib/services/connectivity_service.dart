import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectionStatusController;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Stream<bool> get connectionStream {
    _connectionStatusController ??= StreamController<bool>.broadcast();
    return _connectionStatusController!.stream;
  }

  Future<void> init() async {
    // 检查初始连接状态
    await _checkConnection();

    // 监听连接状态变化
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  Future<void> _checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _updateConnectionStatus(ConnectivityResult.none);
    }
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;

    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        _isConnected = true;
        break;
      case ConnectivityResult.none:
      default:
        _isConnected = false;
        break;
    }

    // 只有在连接状态发生变化时才发送事件
    if (wasConnected != _isConnected) {
      _connectionStatusController?.add(_isConnected);
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  String getConnectionType() {
    if (!_isConnected) return 'Offline';

    return 'Online'; // 简化版本，可以根据需要返回更详细的连接类型
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController?.close();
    _connectionStatusController = null;
  }
}
