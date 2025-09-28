import '../models/todo_event.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'offline_storage_service.dart';
import 'connectivity_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ApiService _apiService = ApiService();
  final OfflineStorageService _offlineService = OfflineStorageService();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  // 执行完整同步
  Future<SyncResult> performFullSync() async {
    if (_isSyncing) {
      return SyncResult.error('同步正在进行中');
    }

    if (!_connectivityService.isConnected) {
      return SyncResult.error('网络连接不可用');
    }

    _isSyncing = true;

    try {
      final result = SyncResult();

      // 1. 上传本地数据到服务器
      final uploadResult = await _uploadLocalData();
      result.uploadedItems = uploadResult.uploadedItems;
      result.uploadErrors.addAll(uploadResult.uploadErrors);

      // 2. 从服务器下载数据
      final downloadResult = await _downloadServerData();
      result.downloadedItems = downloadResult.downloadedItems;
      result.downloadErrors.addAll(downloadResult.downloadErrors);

      // 3. 解决冲突
      await _resolveConflicts();

      result.success = true;
      result.message = '同步完成';

      return result;
    } catch (e) {
      return SyncResult.error('同步失败: ${e.toString()}');
    } finally {
      _isSyncing = false;
    }
  }

  // 上传本地数据到服务器
  Future<SyncResult> _uploadLocalData() async {
    final result = SyncResult();

    try {
      final unsyncedData = await _offlineService.getUnsyncedData();

      for (final record in unsyncedData) {
        try {
          if (record['table_name'] == 'events') {
            await _uploadEvent(record);
            result.uploadedItems++;
          } else if (record['table_name'] == 'tasks') {
            await _uploadTask(record);
            result.uploadedItems++;
          }
        } catch (e) {
          result.uploadErrors.add('上传失败: ${e.toString()}');
        }
      }
    } catch (e) {
      result.uploadErrors.add('获取本地数据失败: ${e.toString()}');
    }

    return result;
  }

  // 从服务器下载数据
  Future<SyncResult> _downloadServerData() async {
    final result = SyncResult();

    try {
      // 下载事件数据
      final eventsResponse = await _apiService.get<List<dynamic>>(
        ApiConstants.events,
        fromJson: (json) => json as List<dynamic>,
      );

      if (eventsResponse.isSuccess && eventsResponse.data != null) {
        for (final eventJson in eventsResponse.data!) {
          try {
            final event = TodoEvent.fromJson(eventJson as Map<String, dynamic>);
            await _offlineService.dbService.insertEvent(event);
            result.downloadedItems++;
          } catch (e) {
            result.downloadErrors.add('下载事件失败: ${e.toString()}');
          }
        }
      }

      // 下载任务数据
      final tasksResponse = await _apiService.get<List<dynamic>>(
        ApiConstants.tasks,
        fromJson: (json) => json as List<dynamic>,
      );

      if (tasksResponse.isSuccess && tasksResponse.data != null) {
        for (final taskJson in tasksResponse.data!) {
          try {
            final task = TodoTask.fromJson(taskJson as Map<String, dynamic>);
            await _offlineService.dbService.insertTask(task);
            result.downloadedItems++;
          } catch (e) {
            result.downloadErrors.add('下载任务失败: ${e.toString()}');
          }
        }
      }
    } catch (e) {
      result.downloadErrors.add('下载服务器数据失败: ${e.toString()}');
    }

    return result;
  }

  // 上传事件到服务器
  Future<void> _uploadEvent(Map<String, dynamic> record) async {
    final isDeleted = (record['is_deleted'] as int) == 1;
    final hasServerId = record['server_id'] != null;

    if (isDeleted && hasServerId) {
      // 删除服务器上的数据
      await _apiService
          .delete('${ApiConstants.eventsById}/${record['server_id']}');
    } else if (hasServerId) {
      // 更新服务器上的数据
      final eventData = _extractEventData(record);
      await _apiService.put(
        '${ApiConstants.eventsById}/${record['server_id']}',
        data: eventData,
      );
    } else if (!isDeleted) {
      // 创建新的服务器数据
      final eventData = _extractEventData(record);
      final response = await _apiService.post(
        ApiConstants.events,
        data: eventData,
      );

      if (response.isSuccess && response.data != null) {
        // 更新本地记录的server_id
        await _offlineService.dbService.markAsSynced('events', record['id']);
      }
    }
  }

  // 上传任务到服务器
  Future<void> _uploadTask(Map<String, dynamic> record) async {
    final isDeleted = (record['is_deleted'] as int) == 1;
    final hasServerId = record['server_id'] != null;

    if (isDeleted && hasServerId) {
      await _apiService
          .delete('${ApiConstants.tasksById}/${record['server_id']}');
    } else if (hasServerId) {
      final taskData = _extractTaskData(record);
      await _apiService.put(
        '${ApiConstants.tasksById}/${record['server_id']}',
        data: taskData,
      );
    } else if (!isDeleted) {
      final taskData = _extractTaskData(record);
      final response = await _apiService.post(
        ApiConstants.tasks,
        data: taskData,
      );

      if (response.isSuccess && response.data != null) {
        await _offlineService.dbService.markAsSynced('tasks', record['id']);
      }
    }
  }

  // 解决数据冲突
  Future<void> _resolveConflicts() async {
    // 简单的冲突解决策略：服务器数据优先
    // 在实际应用中，可以实现更复杂的冲突解决逻辑
  }

  // 离线模式转在线模式
  Future<SyncResult> switchToOnlineMode({
    required String email,
    required String password,
  }) async {
    try {
      // 1. 登录到服务器
      final loginResponse = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (!loginResponse.isSuccess) {
        return SyncResult.error('登录失败: ${loginResponse.message}');
      }

      // 2. 保存认证信息
      await _apiService.saveTokens(
        accessToken: loginResponse.data!['access_token'],
        refreshToken: loginResponse.data!['refresh_token'],
      );

      // 3. 同步离线数据
      final syncResult = await performFullSync();

      // 4. 切换到在线模式
      await _offlineService.setOfflineMode(false);

      return syncResult;
    } catch (e) {
      return SyncResult.error('切换到在线模式失败: ${e.toString()}');
    }
  }

  // 在线模式转离线模式
  Future<SyncResult> switchToOfflineMode() async {
    try {
      // 1. 下载服务器数据到本地
      final downloadResult = await _downloadServerData();

      // 2. 切换到离线模式
      await _offlineService.setOfflineMode(true);

      // 3. 清除认证信息（可选）
      await _apiService.clearTokens();

      return SyncResult(
        success: true,
        message: '已切换到离线模式',
        downloadedItems: downloadResult.downloadedItems,
        downloadErrors: downloadResult.downloadErrors,
      );
    } catch (e) {
      return SyncResult.error('切换到离线模式失败: ${e.toString()}');
    }
  }

  // 辅助方法：提取事件数据
  Map<String, dynamic> _extractEventData(Map<String, dynamic> record) {
    return {
      'title': record['title'],
      'description': record['description'],
      'due_date': record['due_date'],
      'is_completed': record['is_completed'] == 1,
      'priority': record['priority'],
    };
  }

  // 辅助方法：提取任务数据
  Map<String, dynamic> _extractTaskData(Map<String, dynamic> record) {
    return {
      'title': record['title'],
      'description': record['description'],
      'event_id': record['event_id'],
      'due_date': record['due_date'],
      'status': record['status'],
      'priority': record['priority'],
    };
  }
}

// 同步结果类
class SyncResult {
  bool success;
  String message;
  int uploadedItems;
  int downloadedItems;
  List<String> uploadErrors;
  List<String> downloadErrors;

  SyncResult({
    this.success = false,
    this.message = '',
    this.uploadedItems = 0,
    this.downloadedItems = 0,
    List<String>? uploadErrors,
    List<String>? downloadErrors,
  })  : uploadErrors = uploadErrors ?? [],
        downloadErrors = downloadErrors ?? [];

  SyncResult.error(this.message)
      : success = false,
        uploadedItems = 0,
        downloadedItems = 0,
        uploadErrors = [],
        downloadErrors = [];

  bool get hasErrors => uploadErrors.isNotEmpty || downloadErrors.isNotEmpty;

  List<String> get allErrors => [...uploadErrors, ...downloadErrors];
}
