// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '待办清单';

  @override
  String get todoList => '待办事项';

  @override
  String get addTask => '添加任务';

  @override
  String get editTask => '编辑任务';

  @override
  String get taskTitle => '任务标题';

  @override
  String get taskDescription => '任务描述';

  @override
  String get dueDate => '截止日期';

  @override
  String get priority => '优先级';

  @override
  String get high => '高';

  @override
  String get medium => '中';

  @override
  String get low => '低';

  @override
  String get pending => '待完成';

  @override
  String get completed => '已完成';

  @override
  String get overdue => '已过期';

  @override
  String get noTasks => '暂无任务';

  @override
  String get loadFailed => '加载失败';

  @override
  String get retry => '重试';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get confirmDelete => '确认删除';

  @override
  String confirmDeleteMessage(String taskTitle) {
    return '确定要删除\"$taskTitle\"吗？';
  }

  @override
  String get taskCreatedSuccess => '任务创建成功';

  @override
  String get taskUpdatedSuccess => '任务更新成功';

  @override
  String get taskDeletedSuccess => '删除成功';

  @override
  String get createFailed => '创建失败';

  @override
  String get updateFailed => '更新失败';

  @override
  String get deleteFailed => '删除失败';

  @override
  String get today => '今天';

  @override
  String get tomorrow => '明天';

  @override
  String get yesterday => '昨天';

  @override
  String daysLater(int count) {
    return '$count天后';
  }

  @override
  String daysAgo(int count) {
    return '$count天前';
  }

  @override
  String get selectDate => '选择日期';

  @override
  String get onlineMode => '在线模式';

  @override
  String get offlineMode => '离线模式';

  @override
  String get switchMode => '切换模式';

  @override
  String get switchToOnlineMode => '当前为离线模式，是否切换到在线模式？';

  @override
  String get switchToOfflineMode => '当前为在线模式，是否切换到离线模式？';

  @override
  String get switchButton => '切换';

  @override
  String get loading => '加载中...';

  @override
  String get addSubTask => '添加子任务';

  @override
  String get subTasks => '子任务';

  @override
  String subTasksCount(int completed, int total) {
    return '已完成 $completed/$total 个子任务';
  }

  @override
  String get pleaseEnterTaskTitle => '请输入任务标题';

  @override
  String get taskTitleHint => '请输入任务标题';

  @override
  String get taskDescriptionHint => '请输入任务描述（可选）';

  @override
  String viewDetails(String taskTitle) {
    return '查看详情: $taskTitle';
  }

  @override
  String get operationFailed => '操作失败';

  @override
  String get profile => '我的';

  @override
  String get tasks => '任务';
}
